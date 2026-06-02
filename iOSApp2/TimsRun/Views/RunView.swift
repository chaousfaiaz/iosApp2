//
//  RunView.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import SwiftUI

// New run screen: pick teammates and show a readable summary.
struct NewRunView: View {
    @Binding var people: [Person]         // people list comes from the shared store
    @State private var selectedIDs: Set<UUID> = [] // tracks who is checked for this run

    // computed property: gives me the actual Person objects for the selected IDs
    private var selectedPeople: [Person] {
        people.filter { selectedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // list of all teammates
                List {
                    ForEach(people) { person in
                        Button {
                            // toggle checkmark
                            if selectedIDs.contains(person.id) { selectedIDs.remove(person.id) }
                            else { selectedIDs.insert(person.id) }
                        } label: {
                            HStack {
                                Text(person.name).font(.body)
                                Spacer()
                                if selectedIDs.contains(person.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(AppColors.brandRed) // red check
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(rowBackground(for: person)) // cream or light red background
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden) // let my gradient show through
                .overlay {
                    // if no people yet, show placeholder
                    if people.isEmpty {
                        ContentUnavailableView(
                            "No people yet",
                            systemImage: "person.crop.circle.badge.questionmark",
                            description: Text("Add teammates on the People tab.")
                        )
                    }
                }

                Divider().padding(.horizontal)

                // summary of what I selected, easy to read when ordering
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Order Summary").font(.headline)
                    }
                    if selectedPeople.isEmpty {
                        Text("No people selected yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(selectedPeople) { person in
                            if let u = person.usual {
                                Text("• \(person.name): \(orderLine(u))").font(.callout)
                            } else {
                                Text("• \(person.name): (no usual saved)").font(.callout)
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12)) // glassy card
                .padding(.horizontal)
            }
            .navigationTitle("New Run")
        }
    }

    // MARK: - Helpers

    // makes selected rows tinted red and others cream
    private func rowBackground(for person: Person) -> Color {
        selectedIDs.contains(person.id) ? AppColors.brandRed.opacity(0.15)
                                        : AppColors.creamWhite.opacity(0.9)
    }

    // build a readable string for each drink order
    private func orderLine(_ u: DrinkOrder) -> String {
        var parts: [String] = []

        if u.drinkName == "Coffee" {
            if let blend = u.coffeeBlend { parts.append("\(u.size.title) \(blend.title) coffee") }
            else { parts.append("\(u.size.title) coffee") }
            if u.coffeePreset != .custom { parts.append("— \(u.coffeePreset.title)") }
        } else {
            parts.append("\(u.size.title) \(u.drinkName)")
        }

        // only show cream/sugar etc. if not using a preset
        if !(u.drinkName == "Coffee" && u.coffeePreset != .custom) {
            if u.cream > 0 { parts.append("\(u.cream)x cream") }
            if u.milk > 0 {
                parts.append(u.milkType == .regular ? "\(u.milk)x milk" : "\(u.milk)x \(u.milkType.rawValue)")
            }
            if u.sugar > 0 { parts.append("\(u.sugar)x sugar") }
            if u.sweetener > 0 { parts.append("\(u.sweetener)x sweetener") }
        }

        if u.espressoShots > 0 { parts.append("\(u.espressoShots) shot\(u.espressoShots > 1 ? "s" : "")") }

        // add notes if any
        let notes = u.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !notes.isEmpty { parts.append("(\(notes))") }

        return parts.joined(separator: ", ")
    }
}

#Preview { NewRunView(people: .constant([])) } // preview with empty people list
