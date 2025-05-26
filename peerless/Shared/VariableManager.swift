//
//  VariableManager.swift
//  peerless
//
//  Created by Krisna Pranav on 26/05/25.
//

import Foundation

@Observable class VariableManager: ObservableObject {
    static let shared: VariableManager = .init()

    private init() { }
    private var variables = [String: Any]()

    func setVariable(_ key: String, value: Any) {
        Task { @MainActor in
            self.objectWillChange.send()
            self.variables[key] = value
        }
    }

    func getVariable<T>(_ key: String) -> T? {
        return variables[key] as? T
    }

    func removeVariable(_ key: String) {
        Task { @MainActor in
            self.objectWillChange.send()
            self.variables[key] = nil
        }
    }
}
