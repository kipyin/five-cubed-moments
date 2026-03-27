import Foundation

/// Shared formatting for the Review reflection rhythm chart (labels, asset catalog image names). Kept small for tests.
enum ReviewRhythmFormatting {
    static func dayLabel(date: Date, currentWeek: Range<Date>, calendar cal: Calendar) -> String {
        let dayStart = cal.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.calendar = cal
        formatter.locale = cal.locale ?? .current
        formatter.timeZone = cal.timeZone
        if currentWeek.contains(dayStart) {
            formatter.setLocalizedDateFormatFromTemplate("EEE")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("Md")
        }
        return formatter.string(from: dayStart)
    }

    /// Asset catalog names (`empty`, `started`, …) for rhythm column pills.
    static func assetName(for level: JournalCompletionLevel) -> String {
        switch level {
        case .empty:
            "empty"
        case .started:
            "started"
        case .growing:
            "growing"
        case .balanced:
            "balanced"
        case .full:
            "full"
        }
    }
}
