//
//  NotificationsHandler.swift
//  Days
//
//  Created by Anar Seyf on 7/16/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsHandler: NSObject {

    static func requestAuth() {
        let options: UNAuthorizationOptions = [.alert, .badge]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: options) {
            (granted, error) in
            print(granted ? "Granted" : "DENIED")
        }
    }

    static func reset() {
        let center = UNUserNotificationCenter.current() // TODO
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        clearBadge()
    }

    static func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    static func schedule(on date: Date, with model: TimerModel) {

        if (model.state == .invalid) {
            print("Invalid model, cannot schedule notification")
            return
        }

        let formatter = Utils.shared.dateOnlyFormatter
        let now = Date()
        let interval = date.timeIntervalSince(now)
        if interval < 0 {
            print("\(formatter.string(from: date)) is in the past, notification not scheduled")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = model.title ?? Utils.daysString(from: model.totalDays!)
        content.body = formatter.string(from: date)
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)

        print("Scheduled for \(Utils.shared.dateTimeFormatter.string(from: date))")
    }
}
