//
//  ViewController.swift
//  Days
//
//  Created by Anar Seyf on 6/28/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

class DaysSelectorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UNUserNotificationCenterDelegate {
    
    let secondsPerDay = 60 * 60 * 24
    let defaultInterval = 3.0 // TODO - remove

    var days = Array(0...100)
    var selectedInterval: TimeInterval = 0.0 {
        willSet {
            let date = Date(timeIntervalSinceNow: selectedInterval)
            dateLabel.text = dateFormatter.string(from: date)
        }
    }
    var selectedDate: Date? = nil
    var dateFormatter = DateFormatter()
    var loopTimer: Timer? = nil
    var scheduledTimer: Timer? = nil
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        countdownLabel.text = ""
        
        func loopHandler(t: Timer) -> Void {
            if let date = selectedDate {
                let remaining = Int(date.timeIntervalSinceNow)
                let isDone = remaining < 0
                self.countdownLabel.text = (isDone ? "Done" : "\(remaining) seconds remain")
                if (isDone) {
                    notify()
                }
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)

        selectedInterval = defaultInterval

        UNUserNotificationCenter.current().delegate = self
    }
    
    func titleForRow(_ row: Int) -> String {
        return String(days[row])
    }

    func notify() {
        selectedDate = nil

        let content = UNMutableNotificationContent()
        content.title = "Timer done"
        content.body = "Now what?"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) {
            (error) in
            print ("Completed \(error != nil ? "WITH ERRORS" : "").")
        }
    }
    
    @IBAction func startButton(_ sender: UIButton) {

        countdownLabel.isHidden = false
        dateLabel.isHidden = false
        selectedDate = Date(timeIntervalSinceNow: selectedInterval)
    }

    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval = Double(row * secondsPerDay) + defaultInterval
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

