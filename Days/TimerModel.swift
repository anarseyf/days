//
//  TimerModel.swift
//  Days
//
//  Created by Anar Seyf on 6/30/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class TimerModel: NSObject, NSCoding {

    enum ComputedState: String {
        case invalid, inactive, willRun, running, ended
    }

    var isActive = false
    
    var computedState: ComputedState {
        if (startDate == nil || targetDate == nil) {
            return .invalid
        }
        if (startDate! >= targetDate!) {
            return .invalid
        }
        if (!isActive) {
            return .inactive
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

    var targetDate: Date?
    var startDate: Date?
    var title: String?

    var totalDays: Int? {
        if (computedState == .invalid) {
            return nil
        }

        let interval = targetDate!.timeIntervalSince(startDate!)
        return Int(ceil(interval / Double(Utils.secondsPerDay))) // TODO - revise
    }

    var elapsedDays: Int? {
        if (computedState == .invalid) {
            return nil
        }

        let elapsedSeconds = -1 * Int(startDate!.timeIntervalSinceNow)
        let result = (elapsedSeconds / Utils.secondsPerDay) + 1

        return result
    }

    var remainingInterval: TimeInterval? {
        return (computedState == .invalid) ? nil : targetDate!.timeIntervalSinceNow
    }

    var remainingDays: Int? {
        if (computedState == .invalid) { return nil }
        let remainingSeconds = Int(remainingInterval!)
        return remainingSeconds / Utils.secondsPerDay
    }

    override var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let targetString = (targetDate == nil ? "(-)" : formatter.string(from: targetDate!))
        let startString = (startDate == nil ? "(-)" : formatter.string(from: startDate!))
        let titleString = title ?? "(-)"

        return "state: \(computedState)"
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
