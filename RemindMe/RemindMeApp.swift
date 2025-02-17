//
//  RemindMeApp.swift
//  RemindMe
//
//  Created by Jakhongir Nematov on 17/02/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct RemindMeApp: App {
    // ✅ Use a static instance instead of @StateObject here
    private static let sharedNotificationManager = NotificationManager()

    init() {
        // ✅ Set the delegate using the static instance
        UNUserNotificationCenter.current().delegate = RemindMeApp.sharedNotificationManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(RemindMeApp.sharedNotificationManager) // ✅ Use the static instance
        }
        .modelContainer(for: [Reminder.self])
    }
}
