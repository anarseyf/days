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

    enum State: String {
        case notStarted, running, done
    }

    // MARK: - Properties

    let secondsPerDay = 60 * 60 * 24
    let defaultInterval = 6.0 // TODO - remove
    let userDefaultsKeyTargetDate = "targetDate"
    let userDefaultsKeyCreatedDate = "createdDate"

    var state: State = .notStarted {
        didSet {
            switch state {
            case .notStarted:
                startButton.isHidden = false
                resetButton.isHidden = true
                dayLabel.isHidden = true
                countdownLabel.isHidden = true
                picker.isHidden = false
            case .running:
                startButton.isHidden = true
                resetButton.isHidden = false
                dayLabel.isHidden = false
                countdownLabel.isHidden = false
                picker.isHidden = true
            case .done:
                break
            }

            stateLabel.text = state.rawValue
        }
    }

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
    var intervalFormatter = DateComponentsFormatter()
    var loopTimer: Timer? = nil
    var scheduledTimer: Timer? = nil

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: - User action handlers

    @IBAction func startButton(_ sender: UIButton) {
        targetDate = Date(timeIntervalSinceNow: selectedInterval)
        state = .running
    }

    @IBAction func resetButton(_ sender: UIButton) {
        state = .notStarted
        picker.isHidden = false
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        UNUserNotificationCenter.current().delegate = self

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .short
        countdownLabel.text = ""
        
        selectedInterval = defaultInterval

        state = .notStarted

        startLoopTimer()
        restore()
    }

    func startLoopTimer() {

        func loopHandler(t: Timer) -> Void {
            if let date = targetDate {
                let interval = date.timeIntervalSinceNow
                let remaining = Int(date.timeIntervalSinceNow)
                let isDone = remaining < 0
                dayLabel.text = "Day 1"

                if (isDone) {
                    state = .done
                    targetDate = nil
                    notify()
                }
                else {
                    countdownLabel.text = intervalFormatter.string(from: interval)
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
            state = .running
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

