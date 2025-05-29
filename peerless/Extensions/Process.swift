//
//  Process.swift
//  peerless
//
//  Created by Krisna Pranav on 29/05/25.
//

import Foundation
import OSLog

extension Process {
    static func execute(executableURL: URL, arguments: [String]) throws -> (stderr: String, stdout: String) {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let stderr = Pipe()
        let stdout = Pipe()

        process.standardError = stderr
        process.standardOutput = stdout

        try? process.run()
        process.waitUntilExit()

        let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()

        let stderrOutput = String(decoding: stderrData, as: UTF8.self)
        let stdoutOutput = String(decoding: stdoutData, as: UTF8.self)

        return (stderr: stderrOutput, stdout: stdoutOutput)
    }

    static func executeAsync(executableURL: URL, arguments: [String], completion: @escaping (CommandOutput) -> Void) async throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let stderr = Pipe()
        let stdout = Pipe()

        process.standardError = stdout
        process.standardOutput = stdout

        try? process.run()

        let output: CommandOutput = .init()
        let outputQueue: DispatchQueue = .init(label: "genericProcessOutputQueue")
        let log = Logger(subsystem: Logger.subsystem, category: "genericProcess\(executableURL.lastPathComponent)")

        stderr.fileHandleForReading.readabilityHandler = { handle in
            let availableOutput = String(decoding: handle.availableData, as: UTF8.self)
            guard !availableOutput.isEmpty else { return }

            outputQueue.async {
                output.stderr = availableOutput
                completion(output)
                log.debug("[command] [stderr] \(availableOutput)")
            }
        }

        stdout.fileHandleForReading.readabilityHandler = { handle in
            let availableOutput = String(decoding: handle.availableData, as: UTF8.self)
            guard !availableOutput.isEmpty else { return }

            outputQueue.async {
                output.stdout = availableOutput
                completion(output)
                log.debug("[command] [stdout] \(availableOutput)")
            }
        }
    }
}

extension Process {
    enum Stream {
        case stdout
        case stderr
    }

    final class CommandOutput {
        var stdout: String = .init()
        var stderr: String = .init()
    }
}
