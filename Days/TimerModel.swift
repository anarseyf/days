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
        case notStarted = "•"
        case running = "••"
        case done = "•••"
    }

    var state: State = .notStarted // TODO - computed property
    var targetDate: Date?
    var startDate: Date?
    var title: String?

    override var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let targetString = (targetDate == nil ? "(-)" : formatter.string(from: targetDate!))
        let createdString = (startDate == nil ? "(-)" : formatter.string(from: startDate!))
        let titleString = title ?? "(-)"

        return "title: \(titleString); target: \(targetString); created: \(createdString)"
    }

    func encode(with coder: NSCoder) {
        coder.encode(targetDate, forKey: "targetDate")
        coder.encode(startDate, forKey: "createdDate")
        coder.encode(title, forKey: "title")
    }

    required init(coder decoder: NSCoder) {
        self.targetDate = decoder.decodeObject(forKey: "targetDate") as? Date
        self.startDate = decoder.decodeObject(forKey: "createdDate") as? Date
        self.title = decoder.decodeObject(forKey: "title") as? String
    }

    override init() {
    }
}
