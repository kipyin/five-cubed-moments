# Summarization flow

This page follows the real chip label path used now.

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

## Deterministic path

File: `../../GraceNotes/GraceNotes/Services/Summarization/DeterministicChipLabelSummarizer.swift`

Current deterministic behavior:

- label = trimmed full input text

Display truncation is applied separately when needed by:

- `../../GraceNotes/GraceNotes/Services/Summarization/ChipLabelUnitTruncator.swift`

Rule used there:

- 10-unit budget
- Han char counts as 2 units
- Latin char counts as 1 unit
- appends `...` when truncated for display

## Cloud path

File: `../../GraceNotes/GraceNotes/Services/Summarization/CloudSummarizer.swift`

Cloud summarizer:

- calls chat completion API
- returns cloud label on success
- falls back to deterministic summarizer on failure

API key source:

- `../../GraceNotes/GraceNotes/Services/Summarization/ApiSecrets.swift`
- `CloudSummarizationAPIKey` in `../../GraceNotes/Info.plist`

## Where summarization is called

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

Calls happen during chip add/update and async refresh.

## Real clarity note

`NaturalLanguageSummarizer` exists in the repo and has tests:

- `../../GraceNotes/GraceNotes/Services/Summarization/NaturalLanguageSummarizer.swift`
- `../../GraceNotesTests/Services/Summarization/NaturalLanguageSummarizerTests.swift`

But current `SummarizerProvider` route is deterministic/cloud.

## If you know Python

You can think of `SummarizerProvider` as a strategy selector.

It picks an implementation at runtime based on settings.
