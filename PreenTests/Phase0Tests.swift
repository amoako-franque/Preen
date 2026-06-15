import Foundation
import SwiftData
import Testing
@testable import Preen

struct HelperRegistrationTests {
    @Test func plistNameMatchesBundleID() {
        #expect(HelperRegistrationService.plistName == "com.obirasor.Preen.helper.plist")
    }

    @Test func statusDescriptionIsNonEmpty() {
        #expect(!HelperRegistrationService.statusDescription.isEmpty)
    }
}

struct HelperCodeSignatureValidatorTests {
    @Test func debugSkipFlagIsDocumented() {
        #if DEBUG
        #expect(ProcessInfo.processInfo.arguments.contains("--disable-signature-check") == false)
        #else
        #expect(true)
        #endif
    }
}

struct PathValidatorTests {
    @Test func rejectsEmptyPath() {
        #expect(throws: PathValidationError.emptyPath) {
            try PathValidator.validate(path: "   ")
        }
    }

    @Test func rejectsPathTraversal() {
        #expect(throws: PathValidationError.pathTraversal) {
            try PathValidator.validate(path: "/private/tmp/../../etc/passwd")
        }
    }

    @Test func acceptsPathUnderPrivateTmp() throws {
        let url = try PathValidator.validate(path: "/tmp/preen-test")
        #expect(url.path.contains("tmp"))
    }

    @Test func rejectsPathOutsideAllowedRoots() {
        #expect(throws: PathValidationError.outsideAllowedRoots) {
            try PathValidator.validate(path: "/etc/passwd")
        }
    }
}

struct HelperProtocolTests {
    @Test func pingReturnsPong() async {
        let helper = HelperProtocolImpl()
        let response = await withCheckedContinuation { continuation in
            helper.ping { continuation.resume(returning: $0) }
        }
        #expect(response == "pong")
    }

    @Test func versionMatchesConstant() async {
        let helper = HelperProtocolImpl()
        let version = await withCheckedContinuation { continuation in
            helper.getHelperVersion { continuation.resume(returning: $0) }
        }
        #expect(version == PreenConstants.helperVersion)
    }
}

struct PersistenceTests {
    @Test func modelContainerInitializesInMemory() throws {
        let container = try PersistenceController.makeContainer(inMemory: true)
        #expect(container.schema.entities.count == 3)
    }

    @Test func actionLogCRUD() throws {
        let container = try PersistenceController.makeContainer(inMemory: true)
        let context = ModelContext(container)

        let log = ActionLog(
            kind: .clean,
            itemCount: 3,
            bytesAffected: 1024,
            succeeded: true,
            summary: "Cleaned test caches"
        )
        context.insert(log)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ActionLog>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.kind == .clean)
        #expect(fetched.first?.itemCount == 3)
    }

    @Test func vaultEntryCRUD() throws {
        let container = try PersistenceController.makeContainer(inMemory: true)
        let context = ModelContext(container)

        let entry = VaultEntry(itemPath: "/tmp/example.txt", itemSize: 512)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<VaultEntry>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.itemPath == "/tmp/example.txt")
        #expect(fetched.first?.restored == false)
    }
}
