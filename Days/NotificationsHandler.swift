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

    static let notificationDelay: TimeInterval = 1.0

    static func requestAuth() {
        let options: UNAuthorizationOptions = [.alert, .badge]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: options) {
            (granted, error) in
            print(granted ? "Granted" : "DENIED")
        }
    }

    static func reset() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        clearBadge()
    }

    static func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    static func schedule(with model: TimerModel, after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = model.title ?? "Timer expired"
        content.body = (model.targetDate == nil ? "" : Utils.shared.dateTimeFormatter.string(from: model.targetDate!))
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (interval + notificationDelay),
                                                        repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
    }
}
