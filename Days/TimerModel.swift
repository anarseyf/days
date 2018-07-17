//
//  TimerModel.swift
//  Days
//
//  Created by Anar Seyf on 6/30/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class TimerModel: NSObject, NSCoding {

    enum State: String {
        case invalid, willRun, running, ended
    }

    var startDate: Date?
    var targetDate: Date?
    var notificationDate: Date?
    var isActive = false
    var title: String?
    
    var state: State {
        if (startDate == nil || targetDate == nil || startDate! >= targetDate!) {
            return .invalid
        }
        let now = Date()
        if (now < startDate!) {
            return .willRun
        }
        if (now < targetDate!) {
            return .running
        }
        return .ended
    }

    private var totalInterval: TimeInterval? {
        if (state == .invalid) { return nil }
        return targetDate!.timeIntervalSince(startDate!)
    }

    var totalDays: Int? {
        if (state == .invalid) { return nil }
        return Int(ceil(totalInterval! / Double(Utils.secondsPerDay))) // TODO - daylight savings, time zone changes
    }

    var currentDay: Int? { // TODO - negative if start is in future
        if (state != .running) { return nil }

        // TODO - may need to return 0 (.willRun) or total (.ended)
        // for progress bars to update

        let now = Date()
        let elapsedInterval = now.timeIntervalSince(startDate!)
        let result = Int(ceil(elapsedInterval / Double(Utils.secondsPerDay)))

        return result
    }

    var completedDays: Int? {
        switch state {
        case .invalid: return nil
        case .willRun: return 0
        case .ended:   return totalDays!
        case .running: return max(currentDay! - 1, 0)
        }
    }

    var remainingInterval: TimeInterval? {
        switch state {
        case .invalid: return nil
        case .willRun: return totalInterval!
        case .ended:   return 0
        case .running: return targetDate!.timeIntervalSinceNow
        }
    }

    var remainingDays: Int? {
        switch state {
        case .invalid: return nil
        case .willRun: return totalDays!
        case .ended:   return 0
        case .running: return totalDays! - currentDay!
        }
    }

    // Negative if now is before start, positive if now is after end, otherwise nil
    var outsideInterval: TimeInterval? {
        switch state {
        case .invalid:
            return nil
        case .willRun:
            return startDate!.timeIntervalSinceNow // negative
        case .ended:
            return Date().timeIntervalSince(targetDate!) // positive
        case .running:
            return nil
        }
    }

    override var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let targetString = (targetDate == nil ? "(-)" : formatter.string(from: targetDate!))
        let startString = (startDate == nil ? "(-)" : formatter.string(from: startDate!))
        let notificationString = (notificationDate == nil ? "(-)" : formatter.string(from: notificationDate!))
        let titleString = title ?? "(-)"

        return "state: \(state) (\(isActive ? "ACTIVE" : "INACTIVE"))"
            + "\n\ttitle: \(titleString)"
            + "\n\tstart: \(startString)"
            + "\n\ttarget: \(targetString)"
            + "\n\tnotification: \(notificationString)"
    }

    func reset() {
        isActive = false
        targetDate = nil
        startDate = nil
        notificationDate = nil
        title = nil
    }

    func encode(with coder: NSCoder) {
        coder.encode(startDate, forKey: "startDate")
        coder.encode(targetDate, forKey: "targetDate")
        coder.encode(notificationDate, forKey: "notificationDate")
        coder.encode(title, forKey: "title")
        coder.encode(isActive, forKey: "isActive")
    }

    required init(coder decoder: NSCoder) {
        super.init()
        self.startDate = decoder.decodeObject(forKey: "startDate") as? Date
        self.targetDate = decoder.decodeObject(forKey: "targetDate") as? Date
        self.notificationDate = decoder.decodeObject(forKey: "notificationDate") as? Date
        self.title = decoder.decodeObject(forKey: "title") as? String
        self.isActive = decoder.decodeBool(forKey: "isActive")
    }

    override init() {
    }

    static func dateFloor(from date: Date?) -> Date? { // TODO - move to Utils?

        guard let date = date else { return nil }

        var components = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return components.date
    }
}
