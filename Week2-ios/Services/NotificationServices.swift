import Foundation
import UserNotifications

class NotificationService {

    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }

                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }



    private func scheduleNotification(identifier: String, title: String, body: String, at date: Date) {
        cancelReminder(identifier: identifier)

        let calendar = Calendar.current
        
     
        let selectedComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        
        var targetDate = calendar.date(bySettingHour: selectedComponents.hour ?? 0,
                                      minute: selectedComponents.minute ?? 0,
                                      second: 0,
                                      of: Date()) ?? date
        
       
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        }
        
        
        let triggerComponents = calendar.dateComponents([.hour, .minute], from: targetDate)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

       
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error.localizedDescription)")
            } else {
                print("🎯 Successfully scheduled \(identifier) for exact time: \(triggerComponents.hour ?? 0):\(triggerComponents.minute ?? 0)")
            }
        }
    }



    func scheduleDailyReminder(at date: Date) {
        scheduleNotification(
            identifier: "dailyReminder",
            title: "🎮 Time to Play!",
            body: "Play one of your games and improve your high score.",
            at: date
        )
    }

    func scheduleMailReminder(at date: Date) {
        scheduleNotification(
            identifier: "mailReminder",
            title: "📬 Check Your Mail",
            body: "You have new mail reminders waiting for your attention.",
            at: date
        )
    }

    func scheduleTimerReminder(at date: Date) {
        scheduleNotification(
            identifier: "timerReminder",
            title: "⏰ Timer Alert",
            body: "Your scheduled timer reminder is up!",
            at: date
        )
    }


    
    func cancelReminder(identifier: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
