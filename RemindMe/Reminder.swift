import SwiftData
import Foundation
import SwiftUI

/// Reminder lifecycle: Active → Pending (after notification) → Finished (manually)
enum ReminderStatus: String, Codable, CaseIterable {
    case active = "Active"      // Default state when a reminder is created
    case pending = "Pending"    // Moves to this state when the notification is sent
    case finished = "Finished"  // User manually moves to this state
}

enum NotificationInterval: String, Codable, CaseIterable {
    case hour = "Hour"
    case day = "Day"
    case week = "Week"

    var timeInterval: TimeInterval {
        switch self {
        case .hour: return 3600   // 1 hour
        case .day: return 86400   // 1 day
        case .week: return 604800 // 1 week
        }
    }
}

@Model
final class Reminder {
    var title: String
    var notes: String
    var date: Date
    var creationDate: Date // ✅ Added to track when the reminder was created
    var status: ReminderStatus
    var notifyBefore: NotificationInterval
    
    init(title: String, notes: String = "", date: Date, status: ReminderStatus = .active, notifyBefore: NotificationInterval = .day) {
        self.title = title
        self.notes = notes
        self.date = date
        self.creationDate = Date() // ✅ Set the creation date when created
        self.status = status
        self.notifyBefore = notifyBefore
    }

    // Status Icons & Colors
    var statusIcon: String {
        switch status {
        case .active: return "bolt.circle.fill"  // ⚡ New "Active" icon
        case .pending: return "hourglass.circle.fill"
        case .finished: return "checkmark.circle.fill"
        }
    }

    var statusColor: Color {
        switch status {
        case .active: return .blue
        case .pending: return .yellow
        case .finished: return .green
        }
    }
}

