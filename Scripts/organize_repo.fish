#!/usr/bin/env fish

# Run this from the repo root, where you see:
#   FiveCubedMoments/
#   FiveCubedMoments.xcodeproj/
#   FiveCubedMomentsTests/
#   FiveCubedMomentsUITests/

echo "Organizing FiveCubedMoments repo..."

# 1. Create .github/workflows if not present
mkdir -p .github/workflows

# Minimal placeholder CI file (you can replace later)
if not test -f .github/workflows/ios-ci.yml
    begin
        echo "name: iOS CI"
        echo
        echo "on:"
        echo "  pull_request:"
        echo "  push:"
        echo "    branches: [ main ]"
        echo
        echo "jobs:"
        echo "  build-and-test:"
        echo "    runs-on: macos-latest"
        echo "    steps:"
        echo "      - uses: actions/checkout@v4"
        echo "      - name: Xcode version"
        echo "        run: xcodebuild -version"
        echo "      - name: Build and test"
        echo "        run: |"
        echo "          xcodebuild \\"
        echo "            -project FiveCubedMoments/FiveCubedMoments.xcodeproj \\"
        echo "            -scheme FiveCubedMoments \\"
        echo "            -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \\"
        echo "            test"
    end > .github/workflows/ios-ci.yml
    echo "Created .github/workflows/ios-ci.yml"
end

# 2. Create Scripts and Tools directories
mkdir -p Scripts Tools

# 3. Ensure main app folder exists
mkdir -p FiveCubedMoments

# 4. Move Xcode project into app folder (if not already there)
if test -d "FiveCubedMoments.xcodeproj"
    echo "Moving FiveCubedMoments.xcodeproj into FiveCubedMoments/"
    mv FiveCubedMoments.xcodeproj FiveCubedMoments/
end

# 5. Create app source structure
set APP_SRC "FiveCubedMoments/FiveCubedMoments"

mkdir -p \
    "$APP_SRC/Application" \
    "$APP_SRC/Features/Journal/Views" \
    "$APP_SRC/Features/Journal/ViewModels" \
    "$APP_SRC/DesignSystem" \
    "$APP_SRC/Data/Models" \
    "$APP_SRC/Data/Persistence/SwiftData" \
    "$APP_SRC/Services" \
    "$APP_SRC/Utilities" \
    "$APP_SRC/Resources"

# 6. Move existing top-level Swift files into Application/ as a starting point
set has_swift (ls FiveCubedMoments/*.swift 2> /dev/null)
if test (count $has_swift) -gt 0
    echo "Moving top-level Swift files into Application/"
    mv FiveCubedMoments/*.swift "$APP_SRC/Application/"
end

# 7. Create placeholder Swift files if they don't exist yet

# FiveCubedMomentsApp.swift
if not test -f "$APP_SRC/Application/FiveCubedMomentsApp.swift"
    begin
        echo "import SwiftUI"
        echo
        echo "@main"
        echo "struct FiveCubedMomentsApp: App {"
        echo "    var body: some Scene {"
        echo "        WindowGroup {"
        echo "            JournalScreen()"
        echo "        }"
        echo "    }"
        echo "}"
    end > "$APP_SRC/Application/FiveCubedMomentsApp.swift"
    echo "Created $APP_SRC/Application/FiveCubedMomentsApp.swift"
end

# JournalScreen.swift
if not test -f "$APP_SRC/Features/Journal/Views/JournalScreen.swift"
    begin
        echo "import SwiftUI"
        echo
        echo "struct JournalScreen: View {"
        echo "    @StateObject private var viewModel = JournalViewModel()"
        echo
        echo "    var body: some View {"
        echo "        NavigationStack {"
        echo "            Text(\"Five Cubed Moments\")"
        echo "                .navigationTitle(\"Today\")"
        echo "        }"
        echo "    }"
        echo "}"
        echo
        echo "// Preview"
        echo "// struct JournalScreen_Previews: PreviewProvider {"
        echo "//     static var previews: some View {"
        echo "//         JournalScreen()"
        echo "//     }"
        echo "// }"
    end > "$APP_SRC/Features/Journal/Views/JournalScreen.swift"
    echo "Created $APP_SRC/Features/Journal/Views/JournalScreen.swift"
end

# JournalViewModel.swift
if not test -f "$APP_SRC/Features/Journal/ViewModels/JournalViewModel.swift"
    begin
        echo "import Foundation"
        echo
        echo "final class JournalViewModel: ObservableObject {"
        echo "    // TODO: Add properties and logic for today's 5x5 entry"
        echo "}"
    end > "$APP_SRC/Features/Journal/ViewModels/JournalViewModel.swift"
    echo "Created $APP_SRC/Features/Journal/ViewModels/JournalViewModel.swift"
end

# Theme.swift
if not test -f "$APP_SRC/DesignSystem/Theme.swift"
    begin
        echo "import SwiftUI"
        echo
        echo "enum AppTheme {"
        echo "    static let primaryColor = Color.accentColor"
        echo "}"
    end > "$APP_SRC/DesignSystem/Theme.swift"
    echo "Created $APP_SRC/DesignSystem/Theme.swift"
end

# JournalEntry.swift
if not test -f "$APP_SRC/Data/Models/JournalEntry.swift"
    begin
        echo "import Foundation"
        echo
        echo "struct JournalEntry: Identifiable {"
        echo "    let id: UUID"
        echo "    let date: Date"
        echo "    // TODO: Add properties for 5 gratitudes, 5 needs, 5 friends, etc."
        echo "}"
    end > "$APP_SRC/Data/Models/JournalEntry.swift"
    echo "Created $APP_SRC/Data/Models/JournalEntry.swift"
end

# PersistenceController.swift
if not test -f "$APP_SRC/Data/Persistence/SwiftData/PersistenceController.swift"
    begin
        echo "import Foundation"
        echo "import SwiftData"
        echo
        echo "@MainActor"
        echo "final class PersistenceController {"
        echo "    static let shared = PersistenceController()"
        echo
        echo "    let container: ModelContainer"
        echo
        echo "    private init(inMemory: Bool = false) {"
        echo "        let schema = Schema([])"
        echo "        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)"
        echo "        do {"
        echo "            container = try ModelContainer(for: schema, configurations: configuration)"
        echo "        } catch {"
        echo "            fatalError(\"Failed to create SwiftData container: \\(error)\")"
        echo "        }"
        echo "    }"
        echo "}"
    end > "$APP_SRC/Data/Persistence/SwiftData/PersistenceController.swift"
    echo "Created $APP_SRC/Data/Persistence/SwiftData/PersistenceController.swift"
end

# 8. Organize tests: mirror by feature
mkdir -p FiveCubedMomentsTests/Features/Journal
mkdir -p FiveCubedMomentsUITests

# Basic placeholder unit test
if not test -f "FiveCubedMomentsTests/Features/Journal/JournalViewModelTests.swift"
    begin
        echo "import XCTest"
        echo "@testable import FiveCubedMoments"
        echo
        echo "final class JournalViewModelTests: XCTestCase {"
        echo "    func test_initialState_isValid() {"
        echo "        let vm = JournalViewModel()"
        echo "        // TODO: Add real assertions once state is defined"
        echo "        XCTAssertNotNil(vm)"
        echo "    }"
        echo "}"
    end > "FiveCubedMomentsTests/Features/Journal/JournalViewModelTests.swift"
    echo "Created FiveCubedMomentsTests/Features/Journal/JournalViewModelTests.swift"
end

# Basic placeholder UI test
if not test -f "FiveCubedMomentsUITests/JournalUITests.swift"
    begin
        echo "import XCTest"
        echo
        echo "final class JournalUITests: XCTestCase {"
        echo "    func test_example() {"
        echo "        let app = XCUIApplication()"
        echo "        app.launch()"
        echo "        // TODO: Add basic UI assertions"
        echo "    }"
        echo "}"
    end > "FiveCubedMomentsUITests/JournalUITests.swift"
    echo "Created FiveCubedMomentsUITests/JournalUITests.swift"
end

echo "Done. Next steps:"
echo "1) open FiveCubedMoments/FiveCubedMoments.xcodeproj"
echo "2) In Xcode, fix any missing file references and add new files to the targets."
echo "3) Run the app and tests to confirm everything builds."
