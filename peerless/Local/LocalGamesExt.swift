//
//  LocalGamesExt.swift
//  peerless
//
//  Created by Krisna Pranav on 27/05/25.
//

import Foundation

extension LocalGames {
    @available(*, deprecated, message: "Replaced by Peerless.Game")
    struct Game: Codable {
        var title: String
        var imageURL: URL?
        var platform: peerless.Game.Platform
        var path: String
    }
}
