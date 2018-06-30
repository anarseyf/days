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
            dateLabel.text = dateOnlyFormatter.string(from: date) + "\n" + timeOnlyFormatter.string(from: date)
        }
    }
    var targetDate: Date? {
        didSet {
            assert(targetDate == nil || createdDate != nil, "createdDate must be set before targetDate")
            save()
        }
    }
    var createdDate: Date?
    var dateOnlyFormatter = DateFormatter()
    var timeOnlyFormatter = DateFormatter()
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
        createdDate = Date() - Double(secondsPerDay - 10) // TODO - remove!
        targetDate = Date(timeIntervalSinceNow: selectedInterval)
        state = .running
    }

    @IBAction func resetButton(_ sender: UIButton) {
        state = .notStarted

        createdDate = nil
        targetDate = nil

        picker.isHidden = false
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        UNUserNotificationCenter.current().delegate = self

        dateOnlyFormatter.dateStyle = .medium
        dateOnlyFormatter.timeStyle = .none
        timeOnlyFormatter.dateStyle = .none
        timeOnlyFormatter.timeStyle = .medium
        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .short
        countdownLabel.text = ""
        dayLabel.text = ""

        selectedInterval = defaultInterval

        state = .notStarted

        startLoopTimer()
        restore()
    }

    func startLoopTimer() {

        func loopHandler(t: Timer) -> Void {
            if let date = targetDate {
                let remainingInterval = date.timeIntervalSinceNow
                let remainingSeconds = Int(remainingInterval)
                let isDone = remainingSeconds < 0
                let elapsedSeconds = -1 * Int(createdDate!.timeIntervalSinceNow)
                let elapsedDays = (elapsedSeconds / secondsPerDay) + 1
                dayLabel.text = "Day\n\(elapsedDays)"

                if (isDone) {
                    state = .done
                    targetDate = nil
                    notify()
                }
                else {
                    countdownLabel.text = String(elapsedSeconds) + "\n" + intervalFormatter.string(from: remainingInterval)!
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
            let tDate = targetDate!
            let cDate = createdDate!
            print("Saving: \(dateOnlyFormatter.string(from: tDate)) >> \(dateOnlyFormatter.string(from: cDate))")
            defaults.set(tDate, forKey: userDefaultsKeyTargetDate)
            defaults.set(cDate, forKey: userDefaultsKeyCreatedDate)
        }
    }

    func restore() {
        let defaults = UserDefaults.standard
        let restoredTargetDate = defaults.object(forKey: userDefaultsKeyTargetDate)
        let restoredCreatedDate = defaults.object(forKey: userDefaultsKeyCreatedDate)
        if let tDate = restoredTargetDate as? Date,
            let cDate = restoredCreatedDate as? Date {
            print("Restored: \(dateOnlyFormatter.string(from: tDate)) >> \(dateOnlyFormatter.string(from: cDate))")
            createdDate = cDate
            targetDate = tDate
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

