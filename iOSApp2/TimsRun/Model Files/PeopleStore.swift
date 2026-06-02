//
//  PeopleStore.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import Foundation
import Combine

// Shared store for the whole app.
// Holds all the people and auto-saves whenever they change.
final class PeopleStore: ObservableObject {
    @Published var people: [Person] = [] { didSet { save() } }
    // didSet keeps UserDefaults in sync every time the array changes.

    private let key = "people.v1" // version tag so I can migrate data later if needed

    init() { load() } // load saved data right away when the app starts

    private func save() {
        do {
            // encode array into Data and push into UserDefaults
            let data = try JSONEncoder().encode(people)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // encoding shouldn’t fail often, but log it if it does
            print("Save error:", error)
        }
    }

    private func load() {
        // bail if nothing saved yet
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            // decode back into my [Person]
            people = try JSONDecoder().decode([Person].self, from: data)
        } catch {
            // if decode fails (schema change etc), fall back to empty list
            print("Load error:", error)
            people = []
        }
    }
}
