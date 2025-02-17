import SwiftUI
import SwiftData

struct ReminderRow: View {
    let reminder: Reminder
    @ObservedObject var notificationManager: NotificationManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.statusIcon)
                .foregroundColor(reminder.statusColor)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.system(.body, design: .rounded))
                    .bold()

                if !reminder.notes.isEmpty {
                    Text(reminder.notes)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(reminder.date.formatted(.dateTime.month().day().hour().minute()))
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            HStack {
                Image(systemName: "bell.badge")
                    .foregroundColor(.orange)
                Text(reminder.notifyBefore.rawValue)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
