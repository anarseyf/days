//
//  Utils.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class Utils {
    let secondsPerDay = 60 * 60 * 24

    static let shared = Utils()

    let dateOnlyFormatter = DateFormatter()
    let timeOnlyFormatter = DateFormatter()
    let dateTimeFormatter = DateFormatter()
    let intervalFormatter = DateComponentsFormatter()

    private init() {
        
        dateOnlyFormatter.dateStyle = .medium
        dateOnlyFormatter.timeStyle = .none
        timeOnlyFormatter.dateStyle = .none
        timeOnlyFormatter.timeStyle = .medium
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .short

        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .abbreviated
    }
}
