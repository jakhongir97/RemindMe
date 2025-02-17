import SwiftUI
import UserNotifications
import SwiftData

/// Notification name for detecting when a reminder is tapped
extension Notification.Name {
    static let reminderTapped = Notification.Name("reminderTapped")
}

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        requestNotificationPermissions()
        UNUserNotificationCenter.current().delegate = self
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            } else {
                print("Notifications permission granted: \(granted)")
            }
        }
    }

    /// ✅ Show notifications even when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // ✅ Show banner + play sound
    }

    /// ✅ Detect when a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: .reminderTapped, object: nil) // ✅ Notify ContentView
        completionHandler()
    }

    /// ✅ Schedule a notification and update status from `.active` → `.pending`
    func scheduleNotification(for reminder: Reminder, modelContext: ModelContext) {
        let notificationCenter = UNUserNotificationCenter.current()
        let requestID = "\(reminder.hashValue)"

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [requestID])

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.notes
        content.sound = .default

        let notifyBeforeSeconds = reminder.notifyBefore.timeInterval
        let notifyDate = reminder.date.addingTimeInterval(-notifyBeforeSeconds)

        if notifyDate < Date() {
            print("Notification time is in the past. Skipping scheduling...")
            return
        }

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notifyDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for \(reminder.title) at \(notifyDate).")

                DispatchQueue.main.async {
                    self.updateReminderStatusToPending(reminder, modelContext: modelContext)
                }
            }
        }
    }

    private func updateReminderStatusToPending(_ reminder: Reminder, modelContext: ModelContext) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // ✅ Delay to ensure notification was sent
            let now = Date()
            let notifyDate = reminder.date.addingTimeInterval(-reminder.notifyBefore.timeInterval)

            if notifyDate <= now && now <= reminder.date {
                reminder.status = .pending
                do {
                    try modelContext.save()
                    print("✅ Reminder '\(reminder.title)' status changed to Pending.")
                } catch {
                    print("⚠️ Failed to update reminder status: \(error.localizedDescription)")
                }
            }
        }
    }
}

