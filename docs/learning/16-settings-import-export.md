# Settings, import, and export

## Settings entry

File: `../../GraceNotes/GraceNotes/Features/Settings/SettingsScreen.swift`

Main sections:

- AI settings row (toggle + cloud connectivity status)
- Reminders controls
- Data & Privacy section

## Data & Privacy section

File: `../../GraceNotes/GraceNotes/Features/Settings/DataPrivacySettingsSection.swift`

This section shows:

- storage summary
- attention message for iCloud/account state
- optional iCloud sync toggle
- navigation row to import/export screen

It reads runtime persistence state from `persistenceRuntimeSnapshot`.

## Import/export screen

File: `../../GraceNotes/GraceNotes/Features/Settings/ImportExportSettingsScreen.swift`

Actions:

- export JSON backup file
- import JSON backup file

Uses:

- `JournalDataExportService`
- `JournalDataImportService`

## Export service

File: `../../GraceNotes/GraceNotes/Features/Settings/Services/JournalDataExportService.swift`

Behavior:

- fetches all entries sorted by day
- encodes archive payload with schema version
- writes JSON file in temporary directory

## Import service

File: `../../GraceNotes/GraceNotes/Features/Settings/Services/JournalDataImportService.swift`

Safety checks:

- max payload size: 100 MB
- max entry count: 10,000
- schema version check
- dedupe by calendar day (last row wins)
- section item cap to `JournalEntry.slotCount`

Write behavior:

- updates existing day rows when present
- inserts new day rows otherwise

## iCloud account status helper

Files:

- `../../GraceNotes/GraceNotes/Features/Settings/Services/ICloudAccountStatusService.swift`
- `../../GraceNotes/GraceNotes/Features/Settings/ICloudAccountStatusModel.swift`
- `../../GraceNotes/GraceNotes/Features/Settings/Services/ICloudAccountStatusTypes.swift`

This is used to choose guidance text and whether toggle should show.

## If you know Python

Think of import/export services as pure application services.

UI code does file picking and alerts.
Service code does decode/validate/merge rules.
