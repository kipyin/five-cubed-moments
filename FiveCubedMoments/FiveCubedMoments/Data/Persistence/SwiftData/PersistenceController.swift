import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init(inMemory: Bool = false) {
        let schema = Schema([JournalEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            if !inMemory {
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                if let fallback = try? ModelContainer(for: schema, configurations: inMemoryConfig) {
                    container = fallback
                    return
                }
            }
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
