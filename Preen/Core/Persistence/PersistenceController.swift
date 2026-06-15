import Foundation
import SwiftData

enum PersistenceController {
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(PreenSchema.models)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        if inMemory {
            return try ModelContainer(for: schema, configurations: [configuration])
        }

        return try ModelContainer(
            for: schema,
            migrationPlan: PreenMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
