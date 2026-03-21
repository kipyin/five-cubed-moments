# Onboarding flow

## Screen

File: `../../GraceNotes/GraceNotes/Features/Onboarding/OnboardingScreen.swift`  
Type: `OnboardingScreen`

Current onboarding is a 3-page flow.

Each page has:

- title
- message

Controls:

- Continue
- Get Started (on last page)
- Skip for now

## How app decides to show onboarding

File: `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`

`GraceNotesApp` reads:

- `@AppStorage("hasCompletedOnboarding")`

Logic:

- false -> show `OnboardingScreen`
- true -> show main tabs

When onboarding ends, callback sets:

- `hasCompletedOnboarding = true`

## What onboarding teaches

Current copy focuses on:

- low-pressure start
- gentle section prompts
- value of revisiting in Review tab

## Where to change onboarding

Most edits are in `OnboardingScreen.swift`:

- page titles/messages
- button labels
- step count text

If you change onboarding completion behavior, also read:

- `GraceNotesApp.readyContent`

## If you know Python

`@AppStorage` here acts like a small persisted flag in user defaults.

It is not a database model. It is a simple preference/state flag.
