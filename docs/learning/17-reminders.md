# Reminders flow

Reminders are controlled by a view model + scheduler service split.

## Reminder UI state model

File: `../../GraceNotes/GraceNotes/Features/Settings/ReminderSettingsFlowModel.swift`  
Type: `ReminderSettingsFlowModel`

This model owns:

- live reminder status
- selected reminder time
- enable/disable actions
- transient error text

Key methods:

- `refreshStatus()`
- `enableReminders()`
- `disableReminders()`
- `saveEnabledReminderTime()`
- `handleSelectedTimeChanged()`

## Reminder scheduler service

File: `../../GraceNotes/GraceNotes/Services/Reminders/ReminderScheduler.swift`  
Type: `ReminderScheduler`

This service talks to `UNUserNotificationCenter`.

It handles:

- permission state checks
- authorization request (when allowed)
- schedule daily repeating notification
- remove pending reminder request

## Reminder settings constants

File: `../../GraceNotes/GraceNotes/Services/Reminders/ReminderSettings.swift`

Contains:

- key names
- default time
- notification identifier
- helper to get hour/minute components

## Status model used in code

Enums in `ReminderScheduler.swift`:

- `ReminderLiveStatus`
- `ReminderSyncResult`

Examples:

- `.enabled`
- `.off`
- `.denied`
- `.unavailable`

## Where reminders appear in UI

In `SettingsScreen`:

- reminder toggle
- time picker
- denied-state “Open Settings” guidance

File: `../../GraceNotes/GraceNotes/Features/Settings/SettingsScreen.swift`

## If you know Python

This is similar to:

- one stateful UI model class
- one service that wraps OS notification API

The UI model calls the service and maps result into user-facing state.
