import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Reminder>(\.date, order: .forward)]) private var reminders: [Reminder]
    
    @StateObject private var notificationManager = NotificationManager()
    @State private var showingAddReminderSheet = false
    @State private var editingReminder: Reminder?

    var body: some View {
        NavigationStack {
            List {
                if !activeReminders.isEmpty {
                    Section(header: Text("Active").font(.headline)) {
                        ForEach(activeReminders) { reminder in
                            ReminderRow(reminder: reminder, notificationManager: notificationManager)
                                .swipeActions {
                                    Button {
                                        editingReminder = reminder
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }.tint(.blue)

                                    Button(role: .destructive) {
                                        deleteReminder(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                if !pendingReminders.isEmpty {
                    Section(header: Text("Pending").font(.headline)) {
                        ForEach(pendingReminders) { reminder in
                            ReminderRow(reminder: reminder, notificationManager: notificationManager)
                                .swipeActions {
                                    Button {
                                        markAsFinished(reminder)
                                    } label: {
                                        Label("Mark as Finished", systemImage: "checkmark")
                                    }.tint(.green)

                                    Button {
                                        editingReminder = reminder
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }.tint(.blue)

                                    Button(role: .destructive) {
                                        deleteReminder(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                if !finishedReminders.isEmpty {
                    Section(header: Text("Finished").font(.headline)) {
                        ForEach(finishedReminders) { reminder in
                            ReminderRow(reminder: reminder, notificationManager: notificationManager)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteReminder(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddReminderSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                updateReminderStatuses() // ✅ Pull to refresh updates status
            }
            .sheet(isPresented: $showingAddReminderSheet) {
                AddReminderView(notificationManager: notificationManager)
            }
            .sheet(item: $editingReminder) { reminder in
                AddReminderView(notificationManager: notificationManager, editingReminder: reminder)
            }
            .onAppear {
                startReminderStatusCheck() // ✅ Start automatic status checking
            }
            .onReceive(NotificationCenter.default.publisher(for: .reminderTapped)) { _ in
                updateReminderStatuses() // ✅ Update reminders when a notification is tapped
            }
        }
    }

    // MARK: - Filtered Reminders
    private var activeReminders: [Reminder] {
        reminders.filter { $0.status == .active }
    }

    private var pendingReminders: [Reminder] {
        reminders.filter { $0.status == .pending }
    }

    private var finishedReminders: [Reminder] {
        reminders.filter { $0.status == .finished }
    }

    // MARK: - Actions
    private func deleteReminder(_ reminder: Reminder) {
        context.delete(reminder)
        try? context.save()
    }
    
    private func markAsFinished(_ reminder: Reminder) {
        reminder.status = .finished
        try? context.save()
    }

    // MARK: - Auto Status Update (Runs Every Minute)
    private func startReminderStatusCheck() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateReminderStatuses()
        }
    }

    private func updateReminderStatuses() {
        let now = Date()
        for reminder in reminders where reminder.status == .active {
            let notifyDate = reminder.date.addingTimeInterval(-reminder.notifyBefore.timeInterval)
            if notifyDate <= now && now <= reminder.date {
                reminder.status = .pending
            }
        }
        try? context.save()
    }
}

