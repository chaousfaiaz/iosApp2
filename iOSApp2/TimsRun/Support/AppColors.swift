//
//  AppColors.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import SwiftUI

// Central palette so I don't sprinkle raw hex everywhere.
enum AppColors {
    // Tim Hortons-ish core
    static let brandRed       = Color(red: 0.89, green: 0.14, blue: 0.10)  // #E2231A
    static let brandGray      = Color(red: 0.96, green: 0.96, blue: 0.96)  // #F5F5F5
    static let darkRoastBrown = Color(red: 0.29, green: 0.18, blue: 0.16)  // #4B2E2A
    static let espressoBlack  = Color(red: 0.17, green: 0.17, blue: 0.17)  // #2C2C2C

    // Background/accents
    static let creamWhite     = Color(red: 1.00, green: 0.97, blue: 0.91)  // #FFF8E7
    static let sugarWhite     = Color.white
    static let sweetenerPink  = Color(red: 1.00, green: 0.75, blue: 0.80)  // #FFC0CB
    static let icedBlue       = Color(red: 0.65, green: 0.78, blue: 0.91)  // #A7C7E7
}
