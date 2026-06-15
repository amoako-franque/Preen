@preconcurrency import SwiftData

enum PreenMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PreenSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum PreenSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        PreenSchema.models
    }
}
