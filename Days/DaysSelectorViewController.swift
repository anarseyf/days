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

    // MARK: - Properties

    let secondsPerDay = 60 * 60 * 24
    let defaultInterval = 3.0 // TODO - remove
    let userDefaultsKeyTargetDate = "targetDate"
    let userDefaultsKeyCreatedDate = "createdDate"

    var days = Array(0...100)
    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            dateLabel.isHidden = false
            let date = Date(timeIntervalSinceNow: selectedInterval)
            dateLabel.text = dateFormatter.string(from: date)
        }
    }
    var targetDate: Date? {
        didSet {
            if (targetDate != oldValue) {
                save()
            }
        }
    }
    var dateFormatter = DateFormatter()
    var loopTimer: Timer? = nil
    var scheduledTimer: Timer? = nil

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        UNUserNotificationCenter.current().delegate = self

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        countdownLabel.text = ""
        
        selectedInterval = defaultInterval
        startLoopTimer()
        restore()
    }

    func startLoopTimer() {

        func loopHandler(t: Timer) -> Void {
            if let date = targetDate {
                let remaining = Int(date.timeIntervalSinceNow)
                let isDone = remaining < 0
                self.countdownLabel.text = (isDone ? "Done" : "\(remaining) seconds remain")
                if (isDone) {
                    targetDate = nil
                    notify()
                }
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)
    }

    func save() {
        let defaults = UserDefaults.standard
        if (targetDate == nil) {
            print("Removing")
            defaults.removeObject(forKey: userDefaultsKeyTargetDate)
            defaults.removeObject(forKey: userDefaultsKeyCreatedDate)
        }
        else {
            print("Saving: \(dateFormatter.string(from: targetDate!))")
            defaults.set(targetDate, forKey: userDefaultsKeyTargetDate)
            defaults.set(Date(), forKey: userDefaultsKeyCreatedDate)
        }
    }

    func restore() {
        let defaults = UserDefaults.standard
        let restoredTargetDate = defaults.object(forKey: userDefaultsKeyTargetDate)
        if let date = restoredTargetDate as? Date {
            print("Restored: \(dateFormatter.string(from: date))")
            targetDate = date
        }
    }
    
    func titleForRow(_ row: Int) -> String {
        return String(days[row])
    }

    func notify() {
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
            print ("Notification scheduling completed\(error != nil ? " WITH ERRORS" : "").")
        }
    }

    // MARK: - User action handlers
    
    @IBAction func startButton(_ sender: UIButton) {
        countdownLabel.isHidden = false
        targetDate = Date(timeIntervalSinceNow: selectedInterval)
    }

    @IBAction func pickerButton(_ sender: UIButton) { // TODO - remove
        picker.selectRow(3, inComponent: 0, animated: true)
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

