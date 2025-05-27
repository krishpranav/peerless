//
//  LocalGames.swift
//  peerless
//
//  Created by Krisna Pranav on 27/05/25.
//

import Foundation
import SwiftUI
import OSLog

final class LocalGames {
    public static let log = Logger(subsystem: Logger.subsystem, category: "localGames")

    static var library: Set<Game>? {
        get {
            return (try? defaults.decodeAndGet(Set.self, forKey: "localGamesLibrary")) ?? .init()
        }
        set {
            do {
                try defaults.encodeAndSet(newValue, forKey: "localGamesLibrary")
            } catch {
                Logger.app.error("Unable to set to local games library: \(error.localizedDescription)")
            }
        }
    }

    static func launch(game: Mythic.Game) async throws {
        Logger.app.notice("Launching local game \(game.title) (\(game.platform?.rawValue ?? "unknown"))")

        guard let library = library,
              library.contains(game) else {
            log.error("Unable to launch local game, not installed or missing")
            throw GameDoesNotExistError(game)
        }

        Task { @MainActor in
            withAnimation {
                GameOperation.shared.launching = game
            }
        }

        try defaults.encodeAndSet(game, forKey: "recentlyPlayed")

        switch game.platform {
        case .macOS:
            if FileManager.default.fileExists(atPath: game.path ?? .init()) {
                workspace.open(
                    URL(filePath: game.path ?? .init()),
                    configuration: {
                        let configuration = NSWorkspace.OpenConfiguration()
                        configuration.arguments = game.launchArguments
                        return configuration
                    }(),
                    completionHandler: { (_/*game*/, error) in
                        if let error = error {
                            log.error("Error launching local macOS game \"\(game.title)\": \(error)")
                        } else {
                            log.info("Launched local macOS game \"\(game.title)\".")
                        }
                    }
                )
            } else {
                log.critical("\("The game at \(game.path ?? "[Unknown]") doesn't exist, cannot launch local macOS game!")")
            }
        case .windows:
            guard Engine.exists else { throw Engine.NotInstalledError() }
            guard let containerURL = game.containerURL else { throw Wine.ContainerDoesNotExistError() } 
            let container = try Wine.getContainerObject(url: containerURL)

            var environmentVariables = [
                "WINEMSYNC": container.settings.msync.numericalValue.description,
                "ROSETTA_ADVERTISE_AVX": container.settings.avx2.numericalValue.description
            ]

            if container.settings.dxvk {
                environmentVariables["WINEDLLOVERRIDES"] = "d3d10core,d3d11=n,b"
                environmentVariables["DXVK_ASYNC"] = container.settings.dxvkAsync.numericalValue.description
            }

            if container.settings.metalHUD {
                if container.settings.dxvk {
                    environmentVariables["DXVK_HUD"] = "full"
                } else {
                    environmentVariables["MTL_HUD_ENABLED"] = "1"
                }
            }

            try await Wine.command(
                arguments: [game.path!] + game.launchArguments,
                identifier: "launch_\(game.title)",
                containerURL: container.url,
                environment: environmentVariables,
                completion: { _ in }
            )

        case .none:
            do {  }
        }

        if defaults.bool(forKey: "minimiseOnGameLaunch") {
            await NSApp.windows.first?.miniaturize(nil)
        }
        Task { @MainActor in
            GameOperation.shared.launching = nil
        }
    }
}
