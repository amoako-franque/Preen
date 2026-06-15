import Foundation
import SwiftData

enum ActionLogKind: String, Codable, CaseIterable {
    case scan
    case clean
    case optimize
    case uninstall
    case restore
}

@Model
final class ActionLog {
    var id: UUID
    var timestamp: Date
    var kindRawValue: String
    var itemCount: Int
    var bytesAffected: Int64
    var succeeded: Bool
    var summary: String

    var kind: ActionLogKind {
        get { ActionLogKind(rawValue: kindRawValue) ?? .scan }
        set { kindRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        kind: ActionLogKind,
        itemCount: Int,
        bytesAffected: Int64,
        succeeded: Bool,
        summary: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kindRawValue = kind.rawValue
        self.itemCount = itemCount
        self.bytesAffected = bytesAffected
        self.succeeded = succeeded
        self.summary = summary
    }
}

@Model
final class ScanResult {
    var id: UUID
    var scannedAt: Date
    var categoryRawValue: String
    var totalBytes: Int64
    var itemCount: Int

    init(
        id: UUID = UUID(),
        scannedAt: Date = .now,
        categoryRawValue: String,
        totalBytes: Int64,
        itemCount: Int
    ) {
        self.id = id
        self.scannedAt = scannedAt
        self.categoryRawValue = categoryRawValue
        self.totalBytes = totalBytes
        self.itemCount = itemCount
    }
}

@Model
final class VaultEntry {
    var id: UUID
    var createdAt: Date
    var itemPath: String
    var itemSize: Int64
    var restored: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        itemPath: String,
        itemSize: Int64,
        restored: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.itemPath = itemPath
        self.itemSize = itemSize
        self.restored = restored
    }
}

enum PreenSchema {
    static let models: [any PersistentModel.Type] = [
        ActionLog.self,
        ScanResult.self,
        VaultEntry.self,
    ]
}
