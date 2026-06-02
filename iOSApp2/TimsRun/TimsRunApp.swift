//
//  TimsRunApp.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import SwiftUI

@main
struct TimsRunApp: App {
    // one shared store for the whole app (used across both tabs)
    @StateObject private var store = PeopleStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store) // injects the store into the environment
                .tint(AppColors.brandRed) // global accent color (buttons etc.)
        }
    }
}

// I keep ContentView here so the entry point is tidy
struct ContentView: View {
    @EnvironmentObject var store: PeopleStore // pull the shared store from environment

    var body: some View {
        TabView {
            PeopleListView(people: $store.people)
                .tabItem {
                    Label("People", systemImage: "person.3.fill")
                } // tab for managing people

            NewRunView(people: $store.people)
                .tabItem {
                    Label("Run", systemImage: "cup.and.saucer.fill")
                } // tab for creating a new run
        }
        .tint(AppColors.brandRed) // makes selected tab red instead of default blue
        .background(
            LinearGradient(
                colors: [AppColors.creamWhite.opacity(0.9),
                         AppColors.sugarWhite.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea() // gradient goes under the safe area (full screen)
        )
    }
}

#Preview {
    ContentView().environmentObject(PeopleStore()) // preview with empty store
}
