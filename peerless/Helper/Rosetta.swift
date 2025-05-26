//
//  Rosetta.swift
//  peerless
//
//  Created by Krisna Pranav on 26/05/25.
//

import Foundation

final class Rosetta {
    static var exists: Bool { files.fileExists(atPath: "/Library/Apple/usr/share/rosetta") }

    struct AgreementFailure: LocalizedError {
        var errorDescription: String? = """
        Rosetta 2 could not be installed because the software license agreement was not accepted.
        You can review Apple’s Software License Agreements at: https://www.apple.com/legal/sla/
        """
    }

    static func install(agreeToSLA: Bool, completion: @escaping (Double) -> Void) async throws {
        guard agreeToSLA else { throw AgreementFailure() }

        let task = Process()
        task.launchPath = "/usr/sbin/softwareupdate"
        task.arguments = ["--install-rosetta", "--agree-to-license"]
        task.qualityOfService = .userInitiated

        let stdoutPipe = Pipe()
        task.standardOutput = stdoutPipe

        try task.run()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let line = String(decoding: handle.availableData, as: UTF8.self)
            if let match = try? Regex(#"Installing: (\d+(?:\.\d+)?)%"#).firstMatch(in: line) {
                completion(Double(match.last?.substring ?? .init()) ?? 0.0)
            }
        }

        task.waitUntilExit()
    }
}
