import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @ObservedObject var notificationManager: NotificationManager
    
    @State private var title: String
    @State private var notes: String
    @State private var date: Date
    @State private var status: ReminderStatus
    @State private var notifyBefore: NotificationInterval // Updated default value

    var editingReminder: Reminder?

    init(notificationManager: NotificationManager, editingReminder: Reminder? = nil) {
        self.notificationManager = notificationManager
        self.editingReminder = editingReminder

        _title = State(initialValue: editingReminder?.title ?? "")
        _notes = State(initialValue: editingReminder?.notes ?? "")
        _date = State(initialValue: editingReminder?.date ?? Date().addingTimeInterval(3600))
        _status = State(initialValue: editingReminder?.status ?? .active)
        _notifyBefore = State(initialValue: editingReminder?.notifyBefore ?? .hour) // ✅ Changed default from `.day` to `.hour`
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.blue)
                        TextField("Title", text: $title)
                            .font(.system(.body, design: .rounded))
                    }
                    
                    HStack {
                        Image(systemName: "pencil.and.outline")
                            .foregroundColor(.gray)
                        TextField("Notes", text: $notes)
                            .font(.system(.body, design: .rounded))
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.red)
                        DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.orange)
                        Picker("Notify Me", selection: $notifyBefore) {
                            ForEach(NotificationInterval.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Picker("Status", selection: $status) {
                            ForEach(ReminderStatus.allCases, id: \.self) { state in
                                Text(state.rawValue).tag(state)
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingReminder == nil ? "Add Reminder" : "Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editingReminder == nil ? "Save" : "Update") {
                        saveReminder()
                    }
                    .bold()
                }
            }
        }
    }

    private func saveReminder() {
        if let editingReminder {
            editingReminder.title = title
            editingReminder.notes = notes
            editingReminder.date = date
            editingReminder.status = status
            editingReminder.notifyBefore = notifyBefore
        } else {
            let newReminder = Reminder(title: title, notes: notes, date: date, status: status, notifyBefore: notifyBefore)
            context.insert(newReminder)
        }

        do {
            try context.save()
            notificationManager.scheduleNotification(for: editingReminder ?? Reminder(title: title, notes: notes, date: date, status: status, notifyBefore: notifyBefore), modelContext: context)
            dismiss()
        } catch {
            print("Error saving reminder: \(error.localizedDescription)")
        }
    }
}

