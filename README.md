# LitterReminder

An app to schedule and track litter box cleanings. I actually use this app and rely on it.

Tap Mark Complete button to mark the scheduled cleaning as complete. A new cleaning is automatically scheduled the day after tomorrow at 5:00 PM. These settings are configurable. Supports adding a reminder to the iOS Reminders app. Can also schedule a notification when the cleaning is due. The notification supports marking it complete or snoozing until tomorrow. 

Last built with Xcode 26.0.1

- Built with SwiftUI
- Uses SwiftData to persist data
- Uses CloudKit to sync the data
- Creates a reminder using EventKit
- Creates local notifications with actions

<img src="screenshot.png" alt="App screenshot" width="900">
