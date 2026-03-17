# Five Cubed Moments

A 5³ journaling iOS app for daily gratitude, reflection, and people in mind.

## Overview

Five Cubed Moments guides you through a simple daily rhythm: 5 gratitudes, 5 needs, 5 people in mind, reading notes, and space for what you're thinking and learning. The app offers a quiet, low-friction place for gratitude and reflection, with a gentle framing that feels welcoming rather than pushy.

## Features

- **Daily journaling** – Today's 5³ entry with five gratitudes, five needs, five people in mind, reading notes, and reflections. Entries auto-create and save as you type.
- **Sequential input** – Type a full sentence, press Enter; the app summarizes it to a chip label. Tap a chip to edit its text. Supports 5 gratitudes, 5 needs, 5 people.
- **History** – Browse past entries by month and tap any day to view or edit.
- **Shareable cards** – Generate a formatted image of a day's entry and share via the iOS share sheet.
- **Reminders** – Optional daily notification to complete today's 5³.
- **Habit support** – Streak and completion indicators to reinforce the routine without feeling gamified.

## Requirements

- Xcode 15 or later
- iOS 17+

## Getting Started

1. Clone the repository.
2. (Optional) For cloud summarization: copy `ApiSecrets.example.swift` to `FiveCubedMoments/FiveCubedMoments/Services/Summarization/ApiSecrets.swift` and add your API key. Without this, the app uses on-device Natural Language summarization.
3. Open `FiveCubedMoments/FiveCubedMoments.xcodeproj` in Xcode.
4. For code signing, select your development team in the project's Signing & Capabilities (if needed).
5. Select a simulator or device and run (⌘R).

## Tech Stack

- Swift and SwiftUI
- SwiftData for local persistence
- Natural Language framework for summarization
- MVVM-style architecture

## Project Structure

- `FiveCubedMoments/Application` – App entry point
- `FiveCubedMoments/Features/Journal` – Journal UI, view models, and sharing
- `FiveCubedMoments/Data` – Models and persistence (SwiftData)
- `FiveCubedMoments/DesignSystem` – Theming and shared styling
- `FiveCubedMoments/Services` – Summarization (Natural Language + optional cloud API for chip labels)
