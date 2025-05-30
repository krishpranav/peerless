//
//  FileManager.swift
//  peerless
//
//  Created by Krisna Pranav on 28/05/25.
//

import Foundation

extension FileManager {
    func removeItemIfExists(at url: URL) throws {
        if files.fileExists(atPath: url.path) {
            try files.removeItem(at: url)
        }
    }

    func forceCopyItem(at sourceURL: URL, to destinationURL: URL) throws {
        let (stderr, _) = try Process.execute(
            executableURL: .init(filePath: "/bin/cp"),
            arguments: [
                "-f",
                sourceURL.path(percentEncoded: false),
                destinationURL.path(percentEncoded: false)
            ]
        )

        if !stderr.isEmpty {
            throw ForceCopyFailedError()
        }
    }

    struct ForceCopyFailedError: LocalizedError {
        var errorDescription: String? = "Failed to force-copy files."
    }
}
