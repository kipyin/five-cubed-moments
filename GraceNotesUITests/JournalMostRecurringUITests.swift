import XCTest

final class JournalMostRecurringUITests: XCTestCase {
    @MainActor
    private func launchAppWithWideReviewSeed() -> XCUIApplication {
        let app = XCUIApplication()
        app.configureGraceNotesUITestLaunch(resetUITestStore: true, wideReviewRhythm: true)
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Gratitudes"].waitForExistence(timeout: 5),
            "Expected UI test launch to bypass onboarding and open Today screen."
        )
        return app
    }

    private func mainMostRecurringRows(in app: XCUIApplication) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "MostRecurringThemeRow.")
        return app.buttons.matching(predicate)
    }

    private func browseTrendingRows(in app: XCUIApplication) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "TrendingThemeBrowseRow.")
        return app.buttons.matching(predicate)
    }

    private func mainTrendingRows(in app: XCUIApplication) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "TrendingThemeRow.")
        return app.buttons.matching(predicate)
    }

    private func browseMostRecurringRows(in app: XCUIApplication) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "MostRecurringThemeBrowseRow.")
        return app.descendants(matching: .any).matching(predicate)
    }

    private func mostRecurringBrowseSection(_ category: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "MostRecurringBrowseSection.\(category)"))
            .firstMatch
    }

    @MainActor
    private func openPastReviewPanels(_ app: XCUIApplication) {
        app.tabBars.buttons["Past"].tap()
        XCTAssertTrue(
            app.staticTexts["Most recurring"].waitForExistence(timeout: 25),
            "Expected Most recurring panel in Past tab."
        )
        XCTAssertTrue(
            app.staticTexts["Trending"].waitForExistence(timeout: 10),
            "Expected Trending panel in Past tab."
        )
    }

    @MainActor
    func test_reviewScreen_browseAndDrilldown_showMatchingSurfaceContent() {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let rows = mainMostRecurringRows(in: app)
        XCTAssertGreaterThan(rows.count, 0, "Expected at least one Most Recurring row.")
        let firstRow = rows.element(boundBy: 0)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 8), "Expected first Most Recurring row.")
        XCTAssertTrue(firstRow.isHittable, "Expected first Most Recurring row to be tappable.")
        firstRow.tap()
        XCTAssertTrue(
            app.navigationBars["Theme details"].waitForExistence(timeout: 8),
            "Expected drilldown destination from the main recurring section."
        )
        XCTAssertTrue(
            app.staticTexts["Matching writing surfaces"].waitForExistence(timeout: 5),
            "Expected per-surface evidence section in drilldown."
        )
        app.buttons["Done"].tap()

        XCTAssertTrue(
            app.staticTexts["Browse all trending themes"].waitForExistence(timeout: 8),
            "Expected trending browse link."
        )
        app.staticTexts["Browse all trending themes"].tap()

        XCTAssertTrue(
            app.navigationBars["Trending"].waitForExistence(timeout: 8),
            "Expected dedicated trending browse screen."
        )

        let browseRows = browseTrendingRows(in: app)
        XCTAssertGreaterThan(browseRows.count, 0, "Expected browse screen to show trending themes.")
        let firstBrowseRow = browseRows.element(boundBy: 0)
        XCTAssertTrue(firstBrowseRow.waitForExistence(timeout: 8))
        firstBrowseRow.tap()

        XCTAssertTrue(
            app.navigationBars["Theme details"].waitForExistence(timeout: 8),
            "Expected drilldown destination from browse screen."
        )
        XCTAssertTrue(
            app.staticTexts["Matching writing surfaces"].waitForExistence(timeout: 5),
            "Expected per-surface evidence section in drilldown."
        )
        XCTAssertTrue(
            app.staticTexts["Open journal entry"].waitForExistence(timeout: 5),
            "Expected way to open the original entry from drilldown."
        )
    }

    @MainActor
    func test_reviewScreen_mostRecurringAndTrending_cappedAtThreeOnMainPastCard() {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let recurringVisible = mainMostRecurringRows(in: app).count
        let trendingVisible = mainTrendingRows(in: app).count
        XCTAssertGreaterThan(recurringVisible, 0, "Seed should produce at least one recurring theme.")
        XCTAssertGreaterThan(trendingVisible, 0, "Seed should produce at least one trending theme.")
        XCTAssertLessThanOrEqual(recurringVisible, 3, "Main Past card should show at most three recurring rows.")
        XCTAssertLessThanOrEqual(trendingVisible, 3, "Main Past card should show at most three trending rows.")
    }

    @MainActor
    func test_reviewScreen_browseRecurringThemes_opensBrowseList() throws {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let browseLabel = app.staticTexts["Browse all recurring themes"]
        guard browseLabel.waitForExistence(timeout: 12) else {
            throw XCTSkip("Wide review seed did not yield enough recurring themes to show browse link.")
        }
        var scrollAttempts = 0
        while !browseLabel.isHittable && scrollAttempts < 12 {
            app.swipeUp()
            scrollAttempts += 1
        }
        browseLabel.tap()

        let browseRows = browseMostRecurringRows(in: app)
        XCTAssertTrue(
            browseRows.element(boundBy: 0).waitForExistence(timeout: 12),
            "Browse screen should expose at least one recurring theme row."
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["MostRecurringBrowseWindowPicker"].waitForExistence(timeout: 6),
            "Browse screen should include the viewing window control."
        )
    }

    /// Each “Browse all” control must present its own sheet (recurring vs trending), not the wrong destination.
    @MainActor
    func test_reviewScreen_browseAllRecurringThenTrending_openDistinctScreens() throws {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let recurringLink = app.staticTexts["Browse all recurring themes"]
        guard recurringLink.waitForExistence(timeout: 12) else {
            throw XCTSkip("Wide review seed did not yield enough recurring themes to show recurring browse link.")
        }
        var scrollAttempts = 0
        while !recurringLink.isHittable && scrollAttempts < 12 {
            app.swipeUp()
            scrollAttempts += 1
        }
        recurringLink.tap()
        XCTAssertTrue(
            app.navigationBars["Most recurring"].waitForExistence(timeout: 10),
            "Recurring browse should use the Most recurring title."
        )

        let recurringDone = app.navigationBars["Most recurring"].buttons["Done"]
        XCTAssertTrue(recurringDone.waitForExistence(timeout: 6), "Expected Done on the recurring browse sheet.")
        recurringDone.tap()
        XCTAssertTrue(recurringLink.waitForExistence(timeout: 8), "Expected to return to the Past review card.")

        let trendingLink = app.staticTexts["Browse all trending themes"]
        guard trendingLink.waitForExistence(timeout: 12) else {
            throw XCTSkip("Wide review seed did not yield enough trending themes to show trending browse link.")
        }
        scrollAttempts = 0
        while !trendingLink.isHittable && scrollAttempts < 12 {
            app.swipeUp()
            scrollAttempts += 1
        }
        trendingLink.tap()
        XCTAssertTrue(
            app.navigationBars["Trending"].waitForExistence(timeout: 10),
            "Trending browse should use the Trending title, not Most recurring."
        )
    }

    @MainActor
    func test_reviewScreen_mostRecurringBrowse_sectionsBySurfaceKind() throws {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let browseLabel = app.staticTexts["Browse all recurring themes"]
        guard browseLabel.waitForExistence(timeout: 12) else {
            throw XCTSkip("Wide review seed did not yield enough recurring themes to show browse link.")
        }
        var scrollAttempts = 0
        while !browseLabel.isHittable && scrollAttempts < 12 {
            app.swipeUp()
            scrollAttempts += 1
        }
        browseLabel.tap()

        XCTAssertTrue(app.navigationBars["Most recurring"].waitForExistence(timeout: 10))
        XCTAssertTrue(
            mostRecurringBrowseSection("gratitudes", in: app).waitForExistence(timeout: 8),
            "Browse list should section gratitudes."
        )
        XCTAssertTrue(
            mostRecurringBrowseSection("needs", in: app).waitForExistence(timeout: 8),
            "Browse list should section needs."
        )
    }

    @MainActor
    func test_reviewScreen_trendingBrowse_showsNewUpOrDownSection() throws {
        let app = launchAppWithWideReviewSeed()
        openPastReviewPanels(app)

        let trendingLink = app.staticTexts["Browse all trending themes"]
        guard trendingLink.waitForExistence(timeout: 12) else {
            throw XCTSkip("Wide review seed did not yield enough trending themes to show trending browse link.")
        }
        var scrollAttempts = 0
        while !trendingLink.isHittable && scrollAttempts < 12 {
            app.swipeUp()
            scrollAttempts += 1
        }
        trendingLink.tap()

        XCTAssertTrue(app.navigationBars["Trending"].waitForExistence(timeout: 10))
        let newHeader = app.staticTexts["New"]
        let upHeader = app.staticTexts["Up"]
        let downHeader = app.staticTexts["Down"]
        let deadline = Date().addingTimeInterval(8)
        var sawBucketHeader = false
        while Date() < deadline, !sawBucketHeader {
            if newHeader.exists || upHeader.exists || downHeader.exists {
                sawBucketHeader = true
                break
            }
            app.swipeUp()
        }
        XCTAssertTrue(
            sawBucketHeader,
            "Trending browse should group rows under at least one of New, Up, or Down."
        )
        XCTAssertGreaterThan(browseTrendingRows(in: app).count, 0, "Expected at least one trending browse row.")
    }
}
