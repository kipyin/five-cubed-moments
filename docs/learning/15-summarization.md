# Summarization flow

This page follows the real chip label path used now.

Read this page when you want to answer:
- Why did a chip label look this way?
- Why did cloud or fallback path run?

## Contract type

File: `../../GraceNotes/GraceNotes/Services/Summarization/Summarizer.swift`

Key types:

- `Summarizer` protocol
- `SummarizationResult`
- `SummarizationSection`

## Which summarizer is active

File: `../../GraceNotes/GraceNotes/Services/Summarization/SummarizerProvider.swift`

`SummarizerProvider.currentSummarizer()` chooses:

- `CloudSummarizer` when:
  - cloud toggle is on
  - API key is configured
- `DeterministicChipLabelSummarizer` otherwise

So runtime path is settings-driven, not hardcoded by section.

Real snippet:

```swift
if useCloud, ApiSecrets.isCloudApiKeyConfigured {
    return CloudSummarizer(apiKey: ApiSecrets.cloudApiKey)
}
return DeterministicChipLabelSummarizer()
```

## Deterministic path

File: `../../GraceNotes/GraceNotes/Services/Summarization/DeterministicChipLabelSummarizer.swift`

Current deterministic behavior:

- label = trimmed full input text

Then display capping may add `...` depending on provider path.

Real snippet:

```swift
return SummarizationResult(label: trimmed, isTruncated: false)
```

Display truncation is applied separately when needed by:

- `../../GraceNotes/GraceNotes/Services/Summarization/ChipLabelUnitTruncator.swift`

Rule used there:

- 10-unit budget
- Han char counts as 2 units
- Latin char counts as 1 unit
- appends `...` when truncated for display

This keeps chips short and readable in UI rows.

## Cloud path

File: `../../GraceNotes/GraceNotes/Services/Summarization/CloudSummarizer.swift`

Cloud summarizer:

- calls chat completion API
- returns cloud label on success
- falls back to deterministic summarizer on failure

This means cloud failure should not block chip creation.

Real snippets:

```swift
let (data, response) = try await urlSession.data(for: request)
```

```swift
if let result = try? await fallback.summarize(sentence, section: section) {
    return result
}
```

API key source:

- `../../GraceNotes/GraceNotes/Services/Summarization/ApiSecrets.swift`
- `CloudSummarizationAPIKey` in `../../GraceNotes/Info.plist`

## Where summarization is called

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

Calls happen during chip add/update and async refresh.

Search for:
- `summarizeForChip(...)`
- `summarizeAndUpdateChip(...)`

## Real clarity note

`NaturalLanguageSummarizer` exists in the repo and has tests:

- `../../GraceNotes/GraceNotes/Services/Summarization/NaturalLanguageSummarizer.swift`
- `../../GraceNotesTests/Services/Summarization/NaturalLanguageSummarizerTests.swift`

But current `SummarizerProvider` route is deterministic/cloud.

Real snippet from existing NL implementation:

```swift
struct NaturalLanguageSummarizer: Summarizer {
```

## Common confusion

- “Is Natural Language framework currently used for chip labels?”  
  Not through current provider route. Current path is deterministic/cloud.

- “Why is `isTruncated` sometimes false even for long text?”  
  It depends on which path created the label and whether display capping was applied.

- “Does cloud path always mean better labels?”  
  Not guaranteed. App still has deterministic fallback for reliability.

## If you know Python

You can think of `SummarizerProvider` as a strategy selector.

It picks an implementation at runtime based on settings.

## Read next

- Next page: [16-settings-import-export.md](./16-settings-import-export.md)
