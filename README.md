# VirtualPet (Health Friend)

A virtual pet for **Apple Watch** that turns healthy habits into pet care. Your pet's mood and needs reflect how well you sleep and how much you exercise, using data from **HealthKit**. Built with SwiftUI for watchOS.

## Features

- **Pet needs:** hunger, joy and sleep indicators with progress bars, plus a life state that reacts when the pet is neglected.
- **HealthKit integration:** reads sleep analysis and workouts to update the pet's state, with handling for denied authorization.
- **Evolution:** the pet grows from baby to child to adult over time (about 1 and 3 months) and notifies you when it evolves.
- **Animations:** sprite-based pet animations driven by a dedicated animation controller.
- **Notifications:** local notifications for sleepy, evolution and other pet events.
- **Tips:** TipKit hints that explain how to care for the pet and use the Watch's sleep and exercise features.
- **Persistence:** the pet's state is saved with UserDefaults.
- **Localization:** strings managed in a String Catalog.

## Architecture

| Folder | Contents |
| --- | --- |
| `Models/` | Pet state and enums (evolution stages and others) |
| `ViewModels/` | `PetManager`, `EvolutionManager`, `PetAnimationController`, `NotificationManager`, `TipManager`, `CrowViewModel` |
| `ViewModels/HealthKitViewModel/` | `HealthManager` (authorization), `SleepManager`, `WorkoutManager` |
| `ViewModels/StatesViewModel/` | Hunger, joy, sleep and life state logic |
| Views | `PetView`, `EggIntroView`, `IndicatorView`, `ProgressBarView`, `PetNeedsIconsView` |

## Tech stack

![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white) ![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white) ![watchOS](https://img.shields.io/badge/watchOS-000000?style=for-the-badge&logo=apple&logoColor=white) ![HealthKit](https://img.shields.io/badge/HealthKit-FF2D55?style=for-the-badge&logo=apple&logoColor=white) ![TipKit](https://img.shields.io/badge/TipKit-FF9500?style=for-the-badge&logo=apple&logoColor=white) ![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white)

## Running the project

Requirements: Xcode and an Apple Watch or watchOS simulator. TipKit hints need watchOS 10 or later. HealthKit data is limited in the simulator, so use a real device to test sleep and workouts.

1. Clone the repository:
   ```bash
   git clone https://github.com/Luan-Aiezza/VirtualPet.git
   ```
2. Open `VirtualPet.xcodeproj` in Xcode.
3. Select the **VirtualPet Watch App** scheme, choose a watch destination and press **Run** (⌘R).
4. Grant the HealthKit and notification permissions when prompted.

## Author

[Luan Aiezza](https://github.com/Luan-Aiezza)
