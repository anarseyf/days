//
//  TimerModel.swift
//  Days
//
//  Created by Anar Seyf on 6/30/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class TimerModel: NSObject {
    enum State: String {
        case notStarted = "•"
        case running = "••"
        case done = "•••"
    }

    public var state: State = .notStarted
    public var targetDate: Date? // TODO - enforce target/create date parity
    public var createdDate: Date?
}
