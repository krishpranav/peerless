//
//  SemanticVersion.swift
//  peerless
//
//  Created by Krisna Pranav on 29/05/25.
//

import SemanticVersion

extension SemanticVersion {
    var prettyString: String {
        var versionString = "\(major).\(minor).\(patch)"
        if !preRelease.isEmpty {
            versionString += "-\(preRelease)"
        }
        if !build.isEmpty {
            versionString += " (\(build))"
        }
        return versionString
    }
}
