import Foundation

/// Natural language for cloud Review insight *instructions* (not user-facing app strings).
enum CloudReviewInsightsPromptLanguage: Equatable, Sendable {
    /// `zh-Hans` when the app’s active localization is Simplified Chinese; otherwise English.
    case automatic
    case english
    case simplifiedChinese
}

// Prompt blocks are intentionally long; keep line breaks for translators and reviewers.
// swiftlint:disable type_body_length line_length function_body_length
struct CloudReviewInsightsGenerator: ReviewInsightsGenerating {
    private let baseURL: String
    private let model: String
    private let apiKey: String
    private let urlSession: URLSession
    private let promptLanguage: CloudReviewInsightsPromptLanguage
    private let sanitizer = CloudReviewInsightsSanitizer()
    private let maxEntriesForContext = 14

    init(
        baseURL: String = ApiSecrets.cloudAPIBaseURL,
        model: String = "gpt-4o-mini",
        apiKey: String,
        urlSession: URLSession = .shared,
        promptLanguage: CloudReviewInsightsPromptLanguage = .automatic
    ) {
        self.baseURL = baseURL
        self.model = model
        self.apiKey = apiKey
        self.urlSession = urlSession
        self.promptLanguage = promptLanguage
    }

    func generateInsights(
        from entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) async throws -> ReviewInsights {
        let weekRange = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let weeklyEntries = entries
            .filter { weekRange.contains($0.entryDate) }
            .sorted { $0.entryDate < $1.entryDate }
            .suffix(maxEntriesForContext)
        let meaningfulWeeklyEntries = weeklyEntries.filter(\.hasMeaningfulContent)
        guard meaningfulWeeklyEntries.count >= ReviewInsightsCloudEligibility.minimumMeaningfulEntriesForCloudAI else {
            throw CloudReviewInsightsError.insufficientContext
        }

        let contexts = meaningfulWeeklyEntries.map(makeContextEntry)
        let rawPayload = try await callAPI(
            request: CloudReviewInsightsRequest(
                model: model,
                messages: [CloudReviewMessage(role: "user", content: prompt(for: contexts))],
                maxTokens: 800,
                temperature: 0.2
            )
        )
        let payload = sanitizer.sanitizePayload(rawPayload)
        try sanitizer.validateGroundedQuality(payload)
        let weeklyInsights = makeWeeklyInsights(from: payload)

        return ReviewInsights(
            source: .cloudAI,
            generatedAt: referenceDate,
            weekStart: weekRange.lowerBound,
            weekEnd: weekRange.upperBound,
            weeklyInsights: weeklyInsights,
            recurringGratitudes: payload.recurringGratitudes.map { .init(label: $0.label, count: $0.count) },
            recurringNeeds: payload.recurringNeeds.map { .init(label: $0.label, count: $0.count) },
            recurringPeople: payload.recurringPeople.map { .init(label: $0.label, count: $0.count) },
            resurfacingMessage: payload.resurfacingMessage,
            continuityPrompt: payload.continuityPrompt,
            narrativeSummary: payload.narrativeSummary,
            cloudSkippedReason: nil
        )
    }

    private func makeWeeklyInsights(from payload: CloudReviewInsightsPayload) -> [ReviewWeeklyInsight] {
        let primaryTheme = payload.recurringNeeds.first?.label
            ?? payload.recurringPeople.first?.label
            ?? payload.recurringGratitudes.first?.label

        let firstInsight = ReviewWeeklyInsight(
            pattern: .recurringTheme,
            observation: payload.resurfacingMessage,
            action: payload.continuityPrompt,
            primaryTheme: primaryTheme,
            mentionCount: payload.recurringNeeds.first?.count
                ?? payload.recurringPeople.first?.count
                ?? payload.recurringGratitudes.first?.count,
            dayCount: nil
        )

        // `narrativeSummary` maps to the Thinking panel on `ReviewSummaryCard`; keep a single `weeklyInsights`
        // row so the flat payload and this array stay aligned for Observation / Action (#80).
        return [firstInsight]
    }

    private func makeContextEntry(from entry: JournalEntry) -> CloudReviewContextEntry {
        CloudReviewContextEntry(
            date: entry.entryDate.formatted(date: .abbreviated, time: .omitted),
            gratitudes: (entry.gratitudes ?? []).map(\.fullText),
            needs: (entry.needs ?? []).map(\.fullText),
            people: (entry.people ?? []).map(\.fullText),
            readingNotes: entry.readingNotes,
            reflections: entry.reflections
        )
    }

    private func prompt(for entries: [CloudReviewContextEntry]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = (try? encoder.encode(entries)) ?? Data("[]".utf8)
        let contextText = String(data: data, encoding: .utf8) ?? "[]"

        switch resolvedPromptLanguage {
        case .simplifiedChinese:
            return promptSimplifiedChinese(contextText: contextText)
        case .english, .automatic:
            return promptEnglish(contextText: contextText)
        }
    }

    private var resolvedPromptLanguage: CloudReviewInsightsPromptLanguage {
        switch promptLanguage {
        case .automatic:
            switch AppInstructionLocale.preferred(bundle: Bundle.main) {
            case .english:
                return .english
            case .simplifiedChinese:
                return .simplifiedChinese
            }
        case .english, .simplifiedChinese:
            return promptLanguage
        }
    }

    private func promptEnglish(contextText: String) -> String {
        """
        You are generating journaling insights for a guided reflection app.
        Analyze the entries from the past seven days and return STRICT JSON with this shape:
        {
          "narrativeSummary": "string",
          "resurfacingMessage": "string",
          "continuityPrompt": "string",
          "recurringGratitudes": [{"label":"string","count":number}],
          "recurringNeeds": [{"label":"string","count":number}],
          "recurringPeople": [{"label":"string","count":number}]
        }

        Compose mentally in this order, then output all keys: resurfacingMessage (Observation) → narrativeSummary (Thinking) → continuityPrompt (Action). The three strings must read as one story: Thinking extends what Observation surfaced; Action asks about the relationship or tension in Thinking.

        resurfacingMessage — allowed directions (factual only; no character judgments):
        - Frequencies: who/what/which needs appeared how often and across how many days (counts must match the entries).
        - List multiple themes in parallel without interpreting motives.
        - Note which days had fuller vs emptier rows; describe the shape of the record, not motivation.
        - Name which sections had text (gratitudes, needs, people, reflections, reading notes) without interpreting them.
        - Descriptive balance only: which columns were fuller or sparser relative to each other.
        - Single-day spikes vs themes spread across days.
        - If inferable from chips, what was filled in—never discipline or virtue.
        - One standout day: date plus which sections had content—no praise or shame.
        - If one section is consistently empty while others are full, note that asymmetry neutrally (not “you avoided …”).

        narrativeSummary — allowed directions (one sentence; must build on Observation themes; no new entities):
        - Co-occurrence of two or more exact recurring labels across entries or days—different wording than Observation.
        - Neutral contrast or tension between a recurring gratitude theme and a recurring need theme.
        - Add only one layer beyond Observation (co-occurrence, order, early- vs late-week emphasis).
        - Tie reflections or reading notes to chips only when the same wording or image clearly repeats.
        - Early- vs late-week emphasis for the same label when entries support it.
        - People labels that tend to appear alongside a specific gratitude or need label—no relationship quality claims.
        - Reframe Observation into one relational claim with the same evidence.
        - Which category (people vs needs vs gratitudes) drew more mentions—descriptive, not evaluative.
        - Intensity vs spread: a label concentrated on one day vs spread thin.
        - Persistence vs one-off appearances—do not rank “importance.”

        continuityPrompt — allowed directions (one question; must follow Thinking):
        - Ask about the link, tension, or tradeoff named in narrativeSummary.
        - Include at least one label or exact phrasing already present in Observation or Thinking.
        - Short horizon (tomorrow, next few days, one small step this week); invitational, low pressure.
        - Micro-planning: one time block, one conversation, or one boundary tied to the named tension.
        - Gratitude-to-need bridge only when Thinking paired them—no forced causality.
        - People follow-up only for a person label already in play.
        - Reflection/reading hook only when Thinking tied to that text—do not introduce new scripture.
        - Optional either/or (“X or Y first tomorrow?”) with both options grounded in existing labels.
        - Invite the smallest next step when helpful.
        - Do not introduce people, habits, or goals absent from the entries.

        Shared: every line must anchor to the entry JSON or to recurring list labels. Do not comment on language mixing across locales.

        Hard bans (all three fields): no therapy clichés; no motivational filler; no psychologizing the user. Never use phrasing like “shows that you,” “suggests you,” “indicates you value,” “work-life balance” as generic gloss, or invented traits.

        narrativeSummary structure: one sentence that links two concrete signals using the exact label strings from the recurring arrays when two or more strong themes exist; if only one list has a clear theme, tie it to counts or days. When any recurring item has count ≥ 2, include at least one numeral tied to those counts. Use different wording than resurfacingMessage; do not repeat the same counts or sentence structure.

        Bad example (do not imitate): narrativeSummary interprets personality; continuityPrompt ignores the thread and opens a new topic.

        Good example (structure only; use real labels from the entries):
        {"resurfacingMessage":"You noted ThemeA 4 times and ThemeB 3 times this week.","narrativeSummary":"ThemeA showed up alongside ThemeB on most days you wrote.","continuityPrompt":"What is one small way to protect ThemeA tomorrow without dropping ThemeB?","recurringGratitudes":[{"label":"ThemeA","count":4}],"recurringNeeds":[{"label":"ThemeB","count":3}],"recurringPeople":[]}

        Output rules:
        - Do not judge or pressure the user.
        - Do not invent connections the entries do not support.
        - Keep each message under 160 characters.
        - Return at most 3 items per recurring list; counts are positive integers; labels must match phrases you are summarizing from the entries.
        - Output ONLY valid JSON; no markdown fences or prose outside the JSON object.

        Entries from the past seven days:
        \(contextText)
        """
    }

    private func promptSimplifiedChinese(contextText: String) -> String {
        """
        你在为 App「感恩记」的「回顾」准备最近七天的小结：平实、不施压。
        请结合下方最近七天的记录，只输出符合下列结构的 JSON（结构严格；键名用英文，方便程序解析）：
        {
          "narrativeSummary": "string",
          "resurfacingMessage": "string",
          "continuityPrompt": "string",
          "recurringGratitudes": [{"label":"string","count":number}],
          "recurringNeeds": [{"label":"string","count":number}],
          "recurringPeople": [{"label":"string","count":number}]
        }

        心里按此顺序写，再一次性输出各键：先 `resurfacingMessage`（观察）→ `narrativeSummary`（思考）→ `continuityPrompt`（行动）。三段要读成一条线：思考必须承接观察里已经点到的主题；追问必须接着思考里刚说的关系或张力，不要另起无关话题。

        `resurfacingMessage`（观察）允许的方向（只写事实，不写“你是怎样的人”）：
        - 频次：具体的人/事/需要出现几次、跨几天（数字须与记录一致）。
        - 多条主题平铺陈列，不解读动机。
        - 哪些天写得较满、哪些天空白或很短；只描述记录形态。
        - 点出哪些区块有字（感恩、需要、挂念的人、反思、读经笔记），不解释含义。
        - 仅描述相对疏密：哪一栏相对更满或更空。
        - 单日集中出现 vs 分散在多天。
        - 若从条目可看出，写“写了哪些槽位”，不涉及自律或品德评判。
        - 若有特别长的一天，点日期与哪些区块有内容，不表扬不责备。
        - 若某栏持续空、其他栏有内容，用中性笔调写不对称（禁止写“你在逃避…”）。

        `narrativeSummary`（思考 / 规律）允许的方向（一句；必须基于观察里的主题；不得引入新实体）：
        - 两个或以上重复标签在多天或多条里同现——句式要与观察不同。
        - 感恩侧重复主题与需要侧重复主题并置，中性描述张力，不评判性格。
        - 只在观察已有主题上再递进一层：同现、先后顺序、周内前后期侧重等。
        - 反思或读经与 chip 明显重复用词或意象时才可勾连，须点到具体词或标签。
        - 同一标签在周内前后期侧重不同（须有记录支持）。
        - 某人标签常与某感恩或某需要一起出现——不写关系好坏。
        - 把观察压缩成一句“关系型”说法，证据不变。
        - 哪一类（人/需要/感恩）占的笔墨更多——仅描述，不评价。
        - “集中爆发”vs“分散出现”的对照。
        - 持续出现 vs 只出现一两次——不说谁“更重要”。

        `continuityPrompt`（行动 / 追问）允许的方向（一句；必须承接思考）：
        - 针对思考里点到的关系或张力发问（取舍、小尝试、明天先顾哪一头等）。
        - 至少嵌入一个已在观察或思考中出现的标签或同一说法。
        - 时间尺度短（明天、接下来几天、本周一个小步）；语气可接住、不施压。
        - 可邀请一小块时间、一次对话、一个边界，紧扣前述张力。
        - 若思考把感恩与需要并置，可问感恩如何**启发**下一步（不强行因果）。
        - 若思考涉及某人标签，追问只围绕条目里已出现的关心/联络方式。
        - 若思考勾连了反思或读经，追问留在同一文本钩子上，不新开经文话题。
        - 可用“X 还是 Y 明天先做？”式二选一，两者都必须来自已有标签。
        - 可明确邀请“最小一步”（一句话、几分钟、一条信息）。
        - 禁止引入记录里没有的人、习惯或目标。

        共用：每段都必须拴在下方 JSON 记录或各 `recurring*` 列表的标签上。不要点评用户中英混写或语言习惯。

        硬性禁止（三段均适用）：心理诊断式措辞；空洞励志、养生套话；用“显示出/表明/说明你在/珍惜日常小事/工作生活平衡”等空泛升华去概括人格。禁止臆测记录未出现的事实。

        `narrativeSummary` 句式：在有多条清晰重复主题时，用**与 `recurring*` 中完全一致的 label 字符串**把两个具体信号连成一句；若只有一条清晰主线，用次数或天数把它说实。若任一 `recurring` 项 `count` ≥ 2，思考句里须出现至少一个与次数相关的阿拉伯数字。句式须与 `resurfacingMessage` 不同，勿重复同一组数字或同一句骨架。

        坏例子（勿模仿）：思考句写性格升华；追问与思考无关、另起话题。

        好例子（仅结构示意；label 须来自真实记录）：
        {"resurfacingMessage":"这周你写到「主题甲」3 次，也多次提到「主题乙」。","narrativeSummary":"在多条记录里，「主题甲」和「主题乙」常常一起出现。","continuityPrompt":"明天若只能优先一件事，你更想先照顾「主题甲」还是「主题乙」？","recurringGratitudes":[{"label":"主题甲","count":3}],"recurringNeeds":[{"label":"主题乙","count":2}],"recurringPeople":[]}

        输出规则：
        - 不评判、不施压；`narrativeSummary`、`resurfacingMessage`、`continuityPrompt` 正文用简体中文。
        - 每段正文不超过 160 个字；每个 recurring 列表最多 3 条；`count` 为正整数；label 须与所归纳的原文一致。
        - 只输出合法 JSON，不要用 markdown 代码块，不要加任何前言或后记。

        下方是最近七天的记录：
        \(contextText)
        """
    }

    private func callAPI(
        request: CloudReviewInsightsRequest
    ) async throws -> CloudReviewInsightsPayload {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw CloudReviewInsightsError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 15
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw CloudReviewInsightsError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw CloudReviewInsightsError.httpError(statusCode: http.statusCode)
        }

        let content = try decodeAssistantMessageContent(from: data)

        let parsedData = Data(sanitizer.extractJSONPayload(from: content).utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(CloudReviewInsightsPayload.self, from: parsedData)
        } catch {
            throw CloudReviewInsightsError.invalidPayload
        }
    }

    private func decodeAssistantMessageContent(from data: Data) throws -> String {
        let responseBody = try JSONDecoder().decode(CloudReviewInsightsResponse.self, from: data)
        guard let content = responseBody.choices.first?.message.content else {
            throw CloudReviewInsightsError.missingContent
        }
        return content
    }
}
// swiftlint:enable type_body_length line_length function_body_length

private struct CloudReviewInsightsRequest: Encodable {
    let model: String
    let messages: [CloudReviewMessage]
    let maxTokens: Int
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
    }
}

private struct CloudReviewMessage: Codable {
    let role: String
    let content: String
}

private struct CloudReviewInsightsResponse: Decodable {
    let choices: [CloudReviewChoice]
}

private struct CloudReviewChoice: Decodable {
    let message: CloudReviewResponseMessage
}

private struct CloudReviewResponseMessage: Decodable {
    let content: String
}

private struct CloudReviewContextEntry: Encodable {
    let date: String
    let gratitudes: [String]
    let needs: [String]
    let people: [String]
    let readingNotes: String
    let reflections: String
}

struct CloudReviewInsightsPayload: Decodable {
    let narrativeSummary: String
    let resurfacingMessage: String
    let continuityPrompt: String
    let recurringGratitudes: [CloudReviewTheme]
    let recurringNeeds: [CloudReviewTheme]
    let recurringPeople: [CloudReviewTheme]

    enum CodingKeys: String, CodingKey {
        case narrativeSummary
        case resurfacingMessage
        case continuityPrompt
        case recurringGratitudes
        case recurringNeeds
        case recurringPeople
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        narrativeSummary = try container.decodeIfPresent(String.self, forKey: .narrativeSummary) ?? ""
        resurfacingMessage = try container.decodeIfPresent(String.self, forKey: .resurfacingMessage) ?? ""
        continuityPrompt = try container.decodeIfPresent(String.self, forKey: .continuityPrompt) ?? ""
        recurringGratitudes = try container.decodeIfPresent([CloudReviewTheme].self, forKey: .recurringGratitudes) ?? []
        recurringNeeds = try container.decodeIfPresent([CloudReviewTheme].self, forKey: .recurringNeeds) ?? []
        recurringPeople = try container.decodeIfPresent([CloudReviewTheme].self, forKey: .recurringPeople) ?? []
    }

    init(
        narrativeSummary: String,
        resurfacingMessage: String,
        continuityPrompt: String,
        recurringGratitudes: [CloudReviewTheme],
        recurringNeeds: [CloudReviewTheme],
        recurringPeople: [CloudReviewTheme]
    ) {
        self.narrativeSummary = narrativeSummary
        self.resurfacingMessage = resurfacingMessage
        self.continuityPrompt = continuityPrompt
        self.recurringGratitudes = recurringGratitudes
        self.recurringNeeds = recurringNeeds
        self.recurringPeople = recurringPeople
    }
}

struct CloudReviewTheme: Decodable {
    let label: String
    let count: Int

    enum CodingKeys: String, CodingKey {
        case label
        case count
    }

    init(label: String, count: Int) {
        self.label = label
        self.count = count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawLabel = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        label = rawLabel
        if let intVal = try? container.decode(Int.self, forKey: .count) {
            count = max(0, intVal)
        } else if let doubleVal = try? container.decode(Double.self, forKey: .count) {
            count = max(0, Int(doubleVal.rounded()))
        } else if let strVal = try? container.decode(String.self, forKey: .count) {
            let trimmed = strVal.trimmingCharacters(in: .whitespacesAndNewlines)
            count = max(0, Int(trimmed) ?? 1)
        } else {
            count = 1
        }
    }
}

enum CloudReviewInsightsError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case missingContent
    case invalidPayload
    case insufficientContext
    case failedQualityGate
}
