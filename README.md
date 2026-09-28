<video src="demo/mini games.demo.mov" controls width="100%" poster="path/to/thumbnail.png">
  Your browser does not support the video tag.
</video>

# iOS Mini Game Hub

A multi-game SwiftUI application featuring three interactive mini-games, local data tracking, location features, notifications, social sharing, and engaging animations.

## Included Games

* **Tap Frenzy:** A fast-paced tapping game designed to test the user's reflexes.
* **Light It Up:** A puzzle game focused on grid and pattern illumination.
* **Quiz Rush:** A rapid-fire trivia game where users answer questions against the clock.

## Features

* **Multi-Game Navigation:** Seamless navigation between application sections using SwiftUI `TabView`.
* **Game Statistics:** Performance and score history visualized using **Swift Charts**.
* **Local Data Persistence:** High scores, statistics, and settings stored using `UserDefaults`.
* **Map & Location:** **MapKit** and **CoreLocation** integration to display the user's location and gaming-related points of interest.
* **Local Notifications:** **UserNotifications** support for local reminders.
* **Social Sharing:** Native `ShareLink` integration to share game scores and achievements.
* **Dark Mode Support:** Native iOS Dark Mode support for a comfortable gaming experience in different lighting conditions.
* **Leaderboard:** A dedicated leaderboard displaying high scores across the three games.
* **Animations:** SwiftUI animations provide interactive feedback and engaging game experiences.

## Tech Stack

* **Language:** Swift
* **UI/UX:** SwiftUI
* **Animations:** SwiftUI Animations
* **Frameworks:** MapKit, CoreLocation, UserNotifications, Swift Charts
* **Storage:** UserDefaults
* **Navigation:** SwiftUI `TabView`
* **Sharing:** SwiftUI `ShareLink`
* **Development Environment:** Xcode

## Screens

1. **Home:** Main dashboard for accessing the three mini-games and leaderboard.
2. **Statistics:** Visual charts showing gaming history and score performance.
3. **Map:** Displays the user's current location and gaming-related points of interest.
4. **Settings:** Allows users to manage notifications, reset statistics, and customize application preferences.

## Architecture Overview

The application is developed using a **SwiftUI-based architecture**, with separate views and game components for each mini-game. SwiftUI state management handles game interactions and UI updates, while native iOS frameworks provide additional functionality such as maps, location, notifications, charts, and data persistence.

## Known Limitations

* Game scores and settings are stored locally using `UserDefaults`.
* The leaderboard does not use a cloud-based multiplayer system.
* Map locations are provided for demonstration purposes.
* Location-based features require user permission.
* Notifications require user permission.

## Project Structure

The project is organized into separate folders for **Models, Services, and Views**. Some Swift files, such as the main app file and shared UI components, are kept in the main project folder for easy access.


## Reflection

This project provided practical experience in SwiftUI and native iOS development. Developing three different mini-games helped improve my understanding of state management, user interaction, timers, animations, and score handling. I also gained experience integrating native iOS frameworks such as MapKit, CoreLocation, UserNotifications, and Swift Charts into a single application.

## Author

**Imasha Chandramali**


