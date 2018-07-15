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

    var targetDate: Date?
    var startDate: Date?
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
        return Int(floor(totalInterval! / Double(Utils.secondsPerDay))) // TODO - daylight savings, time zone changes
    }

    var currentDay: Int? { // TODO - negative if start is in future
        if (state != .running) { return nil }

        let now = Date()
        let elapsedInterval = now.timeIntervalSince(startDate!)
        let result = Int(floor(elapsedInterval / Double(Utils.secondsPerDay)))

        return result
    }

    var remainingInterval: TimeInterval? {
        if (state != .running) { return nil }
        return targetDate!.timeIntervalSinceNow
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
        let titleString = title ?? "(-)"

        return "state: \(state) (\(isActive ? "ACTIVE" : "INACTIVE"))"
            + "\n\ttitle: \(titleString)"
            + "\n\tstart: \(startString)"
            + "\n\ttarget: \(targetString)"
    }

    func reset() {
        isActive = false
        targetDate = nil
        startDate = nil
        title = nil
    }

    func encode(with coder: NSCoder) {
        coder.encode(startDate, forKey: "startDate")
        coder.encode(targetDate, forKey: "targetDate")
        coder.encode(title, forKey: "title")
        coder.encode(isActive, forKey: "isActive")
    }

    required init(coder decoder: NSCoder) {
        self.startDate = decoder.decodeObject(forKey: "startDate") as? Date
        self.targetDate = decoder.decodeObject(forKey: "targetDate") as? Date
        self.title = decoder.decodeObject(forKey: "title") as? String
        self.isActive = decoder.decodeBool(forKey: "isActive")
    }

    override init() {
    }
}
