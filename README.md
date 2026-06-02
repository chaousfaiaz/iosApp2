# iOSApp2 – TimsRun

SwiftUI iOS app built for Assignment 2 (Mobile Web Development).  
The app manages Tim Hortons coffee runs for a team — each person can have a saved "usual" order, and daily runs track who’s ordering what.  

## Features
- Add teammates and edit their details
- Save a "usual" coffee order with size, blend, preset (e.g. double double), and extras
- Select people for a new run and view a readable order summary
- Data is saved locally using `UserDefaults` so the list persists between app launches
- Custom brand colors and polished UI

## Tech Stack
- SwiftUI
- MVVM-style organization
- `@StateObject` and `@EnvironmentObject` for shared state
- Codable models with persistence in `UserDefaults`




