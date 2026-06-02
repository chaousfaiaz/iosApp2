//
//  Models.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import Foundation

// One saved order. Codable so I can easily store/load from disk.
struct DrinkOrder: Identifiable, Equatable, Codable {
    // Standard Tim's cup sizes
    enum Size: String, CaseIterable, Codable { case small, medium, large, extraLarge }
    // Coffee blend options
    enum CoffeeBlend: String, CaseIterable, Codable { case regularBlend, darkRoast, decaf }
    // Shortcuts for the most common orders (custom = user sets counts)
    enum CoffeePreset: String, CaseIterable, Codable { case black, regular, doubleDouble, tripleTriple, custom }
    // Milk choices
    enum MilkType: String, CaseIterable, Codable { case regular, oat, almond, soy }

    // ID has to be var so Codable can decode a stored one (avoids warning)
    var id: UUID = UUID()

    // Core drink details
    var drinkName: String = "Coffee"
    var size: Size = .medium

    // Coffee-only helpers
    var coffeeBlend: CoffeeBlend? = .regularBlend
    var coffeePreset: CoffeePreset = .custom

    // Customization counts
    var cream: Int = 0
    var milk: Int = 0
    var milkType: MilkType = .regular
    var sugar: Int = 0
    var sweetener: Int = 0
    var espressoShots: Int = 0

    // Notes for special requests
    var notes: String = ""
}

// A person on the team. Can have a saved "usual".
struct Person: Identifiable, Equatable, Codable {
    // Same trick: var so decoding keeps their existing id
    var id: UUID = UUID()
    var name: String
    var usual: DrinkOrder? = nil
}

// MARK: - Friendly titles for UI
// These keep the UI labels human-readable (no raw codes).

extension DrinkOrder.CoffeePreset {
    var title: String {
        switch self {
        case .black:         return "black"
        case .regular:       return "regular"
        case .doubleDouble:  return "double double"
        case .tripleTriple:  return "triple triple"
        case .custom:        return "custom"
        }
    }
}

extension DrinkOrder.CoffeeBlend {
    var title: String {
        switch self {
        case .regularBlend: return "regular blend"
        case .darkRoast:    return "dark roast"
        case .decaf:        return "decaf"
        }
    }
}

extension DrinkOrder.Size {
    var title: String {
        switch self {
        case .small:      return "small"
        case .medium:     return "medium"
        case .large:      return "large"
        case .extraLarge: return "extra large"
        }
    }
}
