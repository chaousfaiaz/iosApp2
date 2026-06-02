//
//  PeopleViews.swift
//  TimsRun
//
//  Created by Kenneth Plumstead on 2025-09-25.
//

import SwiftUI

// MARK: - People List
struct PeopleListView: View {
    @Binding var people: [Person]                 // list comes from the shared store
    @State private var showingAdd = false         // controls the add sheet

    var body: some View {
        NavigationStack {
            List {
                ForEach(people) { person in
                    NavigationLink {
                        // edit screen for this person
                        EditPersonView(person: binding(for: person))
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.headline)
                            // short summary of their usual (or a placeholder)
                            Text(person.usual.map(orderLine) ?? "No usual saved")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true) // avoid truncation dots
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(AppColors.creamWhite.opacity(0.9)) // warm row background
                }
                .onDelete(perform: delete) // swipe-to-delete support
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden) // let my gradient show behind the list
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tint(AppColors.brandRed) // make the add button match brand color
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    // simple add flow: create and append to the array
                    AddPersonView { newPerson in
                        people.append(newPerson)
                        showingAdd = false
                    }
                }
            }
            // catch-all so controls on this screen use my red tint
            .tint(AppColors.brandRed)
        }
    }

    private func delete(at offsets: IndexSet) { people.remove(atOffsets: offsets) }

    // Find a writable binding to the selected person so edits push back into the array.
    private func binding(for person: Person) -> Binding<Person> {
        guard let idx = people.firstIndex(where: { $0.id == person.id }) else { return .constant(person) }
        return $people[idx]
    }

    // Compact, readable order summary for list subtitles.
    private func orderLine(_ u: DrinkOrder) -> String {
        var parts: [String] = []

        if u.drinkName == "Coffee" {
            if let blend = u.coffeeBlend { parts.append("\(u.size.title) \(blend.title) coffee") }
            else { parts.append("\(u.size.title) coffee") }
            if u.coffeePreset != .custom { parts.append("— \(u.coffeePreset.title)") }
        } else {
            parts.append("\(u.size.title) \(u.drinkName)")
        }

        // Only include counts if not using a preset.
        if !(u.drinkName == "Coffee" && u.coffeePreset != .custom) {
            if u.cream > 0 { parts.append("\(u.cream)x cream") }
            if u.milk > 0 {
                parts.append(u.milkType == .regular ? "\(u.milk)x milk" : "\(u.milk)x \(u.milkType.rawValue)")
            }
            if u.sugar > 0 { parts.append("\(u.sugar)x sugar") }
            if u.sweetener > 0 { parts.append("\(u.sweetener)x sweetener") }
        }

        if u.espressoShots > 0 { parts.append("\(u.espressoShots) shot\(u.espressoShots > 1 ? "s" : "")") }

        let notes = u.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !notes.isEmpty { parts.append("(\(notes))") }

        return parts.joined(separator: ", ")
    }
}

// MARK: - Add Person
struct AddPersonView: View {
    @State private var name: String = ""          // local text field state
    let onSave: (Person) -> Void                  // callback to hand the new person back
    @Environment(\.dismiss) private var dismiss   // close the sheet

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words) // better for names
            }
        }
        .navigationTitle("New Person")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { onSave(Person(name: name)); dismiss() }
                    .tint(AppColors.brandRed)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty) // no empty names
            }
        }
        .tint(AppColors.brandRed)
    }
}

// MARK: - Edit Person
struct EditPersonView: View {
    @Binding var person: Person                    // binding into the array
    @State private var tempOrder: DrinkOrder = .init() // edit a temp copy, commit on Save
    @Environment(\.dismiss) private var dismiss

    // Keep the drink list simple for the assignment
    private let baseDrinks = ["Coffee", "Latte", "Cappuccino", "Iced Coffee", "Iced Capp", "Tea", "Other"]

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $person.name)
                    .textInputAutocapitalization(.words)
            }

            Section("Usual Order") {
                // drink type
                Picker("Drink", selection: $tempOrder.drinkName) {
                    ForEach(baseDrinks, id: \.self) { Text($0).tag($0) }
                }

                // size as a menu to avoid truncation on "extra large"
                Picker("Size", selection: $tempOrder.size) {
                    ForEach(DrinkOrder.Size.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(AppColors.brandRed)

                // coffee-specific fields
                if tempOrder.drinkName == "Coffee" {
                    // blend as a menu so the label never gets squeezed
                    Picker("Blend", selection: Binding(
                        get: { tempOrder.coffeeBlend ?? .regularBlend },
                        set: { tempOrder.coffeeBlend = $0 }
                    )) {
                        ForEach(DrinkOrder.CoffeeBlend.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.brandRed)

                    // presets as a dropdown to match the other controls
                    Picker("Preset", selection: $tempOrder.coffeePreset) {
                        ForEach(DrinkOrder.CoffeePreset.allCases, id: \.self) { p in
                            Text(p.title).tag(p)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.brandRed)
                    .onChange(of: tempOrder.coffeePreset) {
                        // auto-fill counts for common presets
                        switch tempOrder.coffeePreset {
                        case .black:         tempOrder.cream = 0; tempOrder.sugar = 0
                        case .regular:       tempOrder.cream = 1; tempOrder.sugar = 1
                        case .doubleDouble:  tempOrder.cream = 2; tempOrder.sugar = 2
                        case .tripleTriple:  tempOrder.cream = 3; tempOrder.sugar = 3
                        case .custom:        break
                        }
                    }
                }

                // standard adjustments
                Stepper("Cream: \(tempOrder.cream)", value: $tempOrder.cream, in: 0...4)
                Stepper("Milk: \(tempOrder.milk)", value: $tempOrder.milk, in: 0...4)

                Picker("Milk type", selection: $tempOrder.milkType) {
                    ForEach(DrinkOrder.MilkType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .disabled(tempOrder.milk == 0) // only matters if I’m adding milk

                Stepper("Sugar: \(tempOrder.sugar)", value: $tempOrder.sugar, in: 0...4)
                Stepper("Sweetener: \(tempOrder.sweetener)", value: $tempOrder.sweetener, in: 0...4)
                Stepper("Espresso shots: \(tempOrder.espressoShots)", value: $tempOrder.espressoShots, in: 0...3)

                TextField("Notes", text: $tempOrder.notes, axis: .vertical)
                    .fixedSize(horizontal: false, vertical: true) // allow multi-line without shrinking
            }

            // quick way to clear a saved usual if it exists
            if person.usual != nil {
                Section {
                    Button(role: .destructive) {
                        person.usual = nil
                        dismiss()
                    } label: { Label("Remove Usual", systemImage: "trash") }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [AppColors.creamWhite.opacity(0.95), AppColors.sugarWhite.opacity(0.8)],
                startPoint: .top, endPoint: .bottom
            )
        )
        .navigationTitle(person.name.isEmpty ? "Edit Person" : person.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { person.usual = tempOrder; dismiss() } // commit temp order
                    .tint(AppColors.brandRed)
            }
        }
        .onAppear { if let u = person.usual { tempOrder = u } } // preload editor with their usual
        .tint(AppColors.brandRed) // keep controls on-brand
    }
}
