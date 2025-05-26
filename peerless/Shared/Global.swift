//
//  Global.swift
//  peerless
//
//  Created by Krisna Pranav on 26/05/25.
//

import Foundation
import SwiftUI
import UserNotifications

let files: FileManager = .default

let defaults: UserDefaults = .standard

let workspace: NSWorkspace = .shared

let sharedApp: NSApplication = .shared

let notifications: UNUserNotificationCenter = .current()

let mainLock: NSRecursiveLock = .init()

var unifiedGames: [Game] { (LocalGames.library ?? []) + ((try? Legendary.getInstallable()) ?? []) }

struct UnknownError: LocalizedError {
    var errorDescription: String? = "An unknown error occurred."
}

func isAppInstalled(bundleIdentifier: String) -> Bool {
    let process: Process = .init()
    process.launchPath = "/usr/bin/env"
    process.arguments = [
        "bash", "-c",
        "mdfind \"kMDItemCFBundleIdentifier == '\(bundleIdentifier)'\""
    ]

    let stdout: Pipe = .init()
    process.standardOutput = stdout
    process.launch()

    let data: Data = stdout.fileHandleForReading.readDataToEndOfFile()
    let output: String = .init(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)

    return !output.isEmpty
}
