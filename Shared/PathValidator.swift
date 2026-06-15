import Foundation

enum PathValidationError: Error, Equatable {
    case emptyPath
    case pathTraversal
    case outsideAllowedRoots
    case couldNotResolve
}

/// Validates paths before the privileged helper performs any file operation.
enum PathValidator {
    static let allowedRoots: [URL] = [
        URL(fileURLWithPath: "/tmp", isDirectory: true),
        URL(fileURLWithPath: "/private/tmp", isDirectory: true),
        URL(fileURLWithPath: "/Library/Caches", isDirectory: true),
        URL(fileURLWithPath: NSHomeDirectory()).appending(path: "Library/Caches", directoryHint: .isDirectory),
    ]

    static func validate(path: String) throws -> URL {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw PathValidationError.emptyPath
        }

        if trimmed.contains("..") {
            throw PathValidationError.pathTraversal
        }

        let url = URL(fileURLWithPath: trimmed)
        let resolved = url.resolvingSymlinksInPath().standardizedFileURL

        let isAllowed = allowedRoots.contains { root in
            let normalizedRoot = root.resolvingSymlinksInPath().standardizedFileURL
            return resolved.path == normalizedRoot.path
                || resolved.path.hasPrefix(normalizedRoot.path + "/")
        }

        guard isAllowed else {
            throw PathValidationError.outsideAllowedRoots
        }

        return resolved
    }
}
