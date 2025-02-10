# 😴 SleepyBell

<img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Images/Cloud.gif" alt="logo" width="250">

A simple alarm application to increase your quality of sleep! Documentation can be found [here](https://joeyhammoth.github.io/SleepyBell/).

---

## 📌 Features

- **Multiple Alarms:**  
  Set a primary alarm along with multiple secondary alarms that remind you to wake up at specified intervals.

- **Sleep Tracking:**  
  Automatically record your wake and sleep times to help you understand your sleep patterns.

- **Data Visualization:**  
  View your sleep data through interactive charts and heat maps, making it easy to analyze your sleeping habits over time.

- **Customizable Notifications:**  
  Schedule local notifications with custom sounds and messages to effectively wake you up.

- **Dynamic UI with SwiftUI:**  
  Enjoy a smooth and intuitive user interface built with SwiftUI, featuring animated transitions, gesture support, and customizable themes (day/night modes).

- **Settings & Personalization:**  
  Adjust various settings including alarm sounds, visual themes, font modifications, and more to suit your personal preferences.

- **Dummy Data Mode for Testing:**  
  Generate random sleep and wake times as well as dates to test the app’s data visualization features without real user data.

- **Core Data Integration:**  
  Persist alarms, settings, and sleep statistics using Core Data, ensuring your data is stored reliably.

### Day/Night Animated Background
<p>
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Sunny.gif" style="display: inline;" alt="loosing-game" width="250">
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Stars.gif" style="display: inline;" alt="loosing-game" width="250">
</p>

### Font Modification
<p>
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/FontSize.gif" style="display: inline;" alt="loosing-game" width="250">
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Fonts1.gif" style="display: inline;" alt="loosing-game" width="250">
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Fonts2.gif" style="display: inline;" alt="loosing-game" width="250">
</p>

### App Navigation
<p>
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Net.gif" style="display: inline;" alt="loosing-game" width="250">
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Sections.gif" style="display: inline;" alt="loosing-game" width="250">
</p>

### Miscellaneous
<p>
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/DarkLight.gif" style="display: inline;" alt="loosing-game" width="250">
   <img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Demos/gifs/Deletion.gif" style="display: inline;" alt="loosing-game" width="250">
</p>

### Alarm Functionality

https://github.com/user-attachments/assets/799e76c1-2e78-426a-aeaa-4036f3d16359

https://github.com/user-attachments/assets/1155b44b-6b04-4d61-b8f5-1ecd403b27c1

https://github.com/user-attachments/assets/a45d3818-3dcc-492c-bdc7-ae69f82dd0c4

---

## 📸 Project Structure

```bash
.
├── AlarmListEntity.xcdatamodeld
│   └── AlarmListEntity.xcdatamodel
│       └── contents
├── Assets.xcassets
│   ├── AccentColor.colorset
│   │   └── Contents.json
│   ├── AppIcon.appiconset
│   │   ├── Contents.json
│   │   └── final.png
│   └── Contents.json
├── ContentView.swift
├── Data.swift
├── Database.xcdatamodeld
│   └── Database.xcdatamodel
│       └── contents
├── DayNight.swift
├── Form.swift
├── Info.plist
├── Notifications.swift
├── Preview Content
│   └── Preview Assets.xcassets
│       └── Contents.json
├── Settings.swift
├── SleepyBellApp.swift
├── Sounds
│   └── lottery.wav
└── Statistics.swift
```
<img src="https://github.com/JoeyHammoth/SleepyBell/blob/main/Images/diagram.png" alt="logo" width="1000" height="100">

The SleepyBell project is organized into several key components:

- **Views:**  
  Contains SwiftUI views for the main interface, settings, notifications, and statistics.  
  _Example folders:_
  - `ContentView.swift` – Main interface and alarm management.
  - `Settings.swift` – User settings and customization.
  - `Notifications.swift` – Management of local notifications.
  - `Statistics.swift` – Sleep tracking and data visualization.

- **Models:**  
  Defines data models for alarms, sleep events, and aggregated statistics.  
  _Example files:_
  - `AlarmList.swift` – Model for managing alarm data.
  - `Data.swift` – Core Data model extensions and persistence controller.
  - `Statistics.swift` – Data structures for sleep events and heat map data.

- **Supporting Files:**  
  Contains assets, configurations, and other resources such as icons, animations (e.g., `Cloud.gif`), and the app’s metadata.

- **Core Data:**  
  Core Data entities and persistence logic are handled in the `Data.swift` file, with extensions to convert between Core Data storage formats and native Swift types.

- **Charts & Visualization:**  
  Implements charts and graphs using Apple’s Charts framework to display sleep statistics in an engaging way.

---

## 🚀 Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/JoeyHammoth/SleepyBell.git
   cd SleepyBell
   ```
2. **Open in Xcode:**  
   Open the `SleepyBell.xcodeproj` file in Xcode 13 or later.
3. **Run the app:**  
   Build and run the app on the iOS simulator or deploy it directly to an iOS device.

### Dependencies
This project requires the SwiftUI introspect package that can be found [here](https://github.com/siteline/SwiftUI-Introspect).

---

## 🛠️ Usage

- **Launching the App:**  
  Simply launch the app on your device to access the main interface where you can set your alarms.

- **Setting Alarms:**  
  Configure your primary and secondary alarms using the intuitive interface. Customize alarm times, select sound options, and modify settings as desired.

- **Managing Notifications:**  
  View and manage your scheduled notifications within the Notifications section. Delete or modify alarms as needed.

- **Viewing Statistics:**  
  Navigate to the Statistics section to explore interactive charts and heat maps. Use pinch-to-zoom and pan gestures to dive deeper into your sleep data.

- **Customizing Settings:**  
  Access the Settings view to adjust various aesthetic and functional preferences such as theme, font, and star count (for night mode).

- **Testing with Dummy Data:**  
  Enable the dummy data mode if you wish to test the visualization components without using your actual sleep data.

---

## 📜 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

We welcome contributions from the community! To get started:

1. **Fork the repository.**
2. **Create a feature branch:**  
   ```sh
   git checkout -b feature/YourFeatureName
   ```
3. **Commit your changes:**  
   Follow the existing code style and ensure your changes are well-documented.
4. **Push to your fork:**  
   ```sh
   git push origin feature/YourFeatureName
   ```
5. **Submit a pull request.**

Please review our contribution guidelines [here](CONTRIBUTING.md). Please also review our [security policy](SECURITY.md) and [code of conduct](CODE_OF_CONDUCT.md).

---

## 📖 Documentation

Detailed documentation for the project, including design decisions and code architecture, can be found in the [Wiki](https://github.com/JoeyHammoth/SleepyBell/wiki).

---

## 🔮 Future Enhancements

- **HealthKit Integration:**  
  Sync sleep data with Apple Health for a more comprehensive view of your overall wellness.

- **Advanced Analytics:**  
  Implement machine learning algorithms to predict sleep quality and provide personalized sleep improvement recommendations.

- **Enhanced Customization:**  
  Expand the range of themes, sounds, and user interface customization options.

- **Cross-Platform Support:**  
  Extend SleepyBell to work on other Apple platforms such as iPadOS and macOS.

---

## Authors
- **JoeyHammoth** - [My GitHub Profile](https://github.com/JoeyHammoth)

---

## 📘 Citations and Acknowledgments

This project requires the use of swiftUI introspect package which can be found [here](https://github.com/siteline/SwiftUI-Introspect). Alarm sound effects are taken from mixkit and can be found [here](https://mixkit.co/free-sound-effects/alarm/). Icons are provided by Apple via their SF symbols asset. Special thanks to the open-source community for providing tools and resources that made this project possible.

---

😄 Happy Sleeping and Productive Waking with SleepyBell!
