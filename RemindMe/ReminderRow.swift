import SwiftUI
import SwiftData

struct ReminderRow: View {
    let reminder: Reminder
    @ObservedObject var notificationManager: NotificationManager

    @State private var currentTime = Date() // ✅ Triggers UI update every minute

    var body: some View {
        VStack(spacing: 8) {
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
            }

            // ✅ Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(progressColor)
                .frame(height: 6)
                .clipShape(Capsule())

            // ✅ Time Remaining Below Progress Bar
            Text(timeRemaining)
                .font(.footnote)
                .foregroundColor(progressColor)
                .bold()
                .padding(.top, 2)
        }
        .padding(.vertical, 8)
        .onAppear {
            startTimer() // ✅ Start updating every minute
        }
    }

    // MARK: - Timer to Refresh UI Every Minute
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Progress Bar Logic
    private var progress: Double {
        let totalTime = reminder.date.timeIntervalSince(reminder.creationDate) // Total time until due
        let elapsedTime = currentTime.timeIntervalSince(reminder.creationDate) // Time that has passed
        return max(0, min(1, elapsedTime / totalTime)) // Keep progress between 0 and 1
    }

    private var progressColor: Color {
        if progress < 0.33 { return .green }  // ✅ First 1/3 → Green
        if progress < 0.66 { return .yellow } // ✅ Second 1/3 → Yellow
        return .red                            // ✅ Last 1/3 → Red
    }

    // MARK: - Time Remaining Logic
    private var timeRemaining: String {
        let remainingSeconds = max(0, reminder.date.timeIntervalSince(currentTime))

        let days = Int(remainingSeconds / 86400)  // 1 day = 86400 sec
        let hours = Int((remainingSeconds.truncatingRemainder(dividingBy: 86400)) / 3600) // Remaining hours
        let minutes = Int((remainingSeconds.truncatingRemainder(dividingBy: 3600)) / 60)  // Remaining minutes

        if days > 0 {
            return "\(days)d \(hours)h left"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else {
            return "\(minutes)m left"
        }
    }
}
