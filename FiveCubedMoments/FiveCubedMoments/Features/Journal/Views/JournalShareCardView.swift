import SwiftUI

struct JournalShareCardView: View {
    let payload: JournalExportPayload

    private static let cardWidth: CGFloat = 400
    private static let padding: CGFloat = 24
    private static let titleFont = Font.title2.weight(.semibold)
    private static let sectionFont = Font.headline
    private static let bodyFont = Font.body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(payload.dateFormatted)
                .font(JournalShareCardView.titleFont)
                .foregroundStyle(Color.primary)

            sectionIfNonEmpty("Gratitudes", items: payload.gratitudes)
            sectionIfNonEmpty("Needs", items: payload.needs)
            sectionIfNonEmpty("People To Pray For", items: payload.people)

            if !payload.bibleNotes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bible Notes")
                        .font(JournalShareCardView.sectionFont)
                    Text(payload.bibleNotes)
                        .font(JournalShareCardView.bodyFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !payload.reflections.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Reflections")
                        .font(JournalShareCardView.sectionFont)
                    Text(payload.reflections)
                        .font(JournalShareCardView.bodyFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(width: JournalShareCardView.cardWidth)
        .padding(JournalShareCardView.padding)
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func sectionIfNonEmpty(_ title: String, items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(JournalShareCardView.sectionFont)
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text("\(index + 1). \(item)")
                        .font(JournalShareCardView.bodyFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
