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

    var createdDate: Date?
    var dateOnlyFormatter = DateFormatter()
    var timeOnlyFormatter = DateFormatter()
    var dateTimeFormatter = DateFormatter()
    var intervalFormatter = DateComponentsFormatter()
    var loopTimer: Timer? = nil
    var scheduledTimer: Timer? = nil
    var days = Array(0...100)
    var state: State = .notStarted {
        didSet {
            switch state {
            case .notStarted:
                resetButton.isHidden = true
                dayLabel.isHidden = true
                remainingLabel.isHidden = true
                countdownLabel.isHidden = true
                startButton.isHidden = false
                picker.isHidden = false
            case .running:
                startButton.isHidden = true
                picker.isHidden = true
                resetButton.isHidden = false
                dayLabel.isHidden = false
                remainingLabel.isHidden = false
                countdownLabel.isHidden = false
            case .done:
                break
            }

            stateLabel.text = state.rawValue
        }
    }
    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let date = Date(timeIntervalSinceNow: selectedInterval)
            targetDateLabel.text = dateOnlyFormatter.string(from: date) + "\n" + timeOnlyFormatter.string(from: date)
        }
    }
    var targetDate: Date? {
        didSet {
            assert(targetDate == nil || createdDate != nil, "createdDate must be set before targetDate")
            save()
        }
    }
    var showDetails: Bool = false {
        didSet {
            detailsView.isHidden = !showDetails
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var detailsView: UIStackView!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: - User action handlers

    @IBAction func startButton(_ sender: UIButton) {
        createdDate = Date()
        let date = Date(timeIntervalSinceNow: selectedInterval)
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        print("\(components.hour?.description ?? "-") h, \(components.minute?.description ?? "-") m")
//        components.hour = 23 // TODO
//        components.minute = 59
//        components.second = 59
        targetDate = components.date

        state = .running // TODO - move to targetDate setter?
    }

    @IBAction func resetButton(_ sender: UIButton) {
        state = .notStarted

        createdDate = nil
        targetDate = nil

        picker.isHidden = false
    }

    @IBAction func toggleButton(_ sender: UIButton) {
        showDetails = !showDetails
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
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .medium

        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .short
        
        countdownLabel.text = ""
        dayLabel.text = ""
        remainingLabel.text = ""

        showDetails = false

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
                let remainingDays = remainingSeconds / secondsPerDay + 1
                let isDone = remainingSeconds < 0
                let elapsedSeconds = -1 * Int(createdDate!.timeIntervalSinceNow)
                let elapsedDays = (elapsedSeconds / secondsPerDay) + 1 // TODO - prevent overrun if we're past targetDate

                dayLabel.text = "Day\n\(elapsedDays)"
                remainingLabel.text = "\(remainingDays) \(remainingDays == 1 ? "day remains" : "days remain")"

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
            print("Saving: \(dateTimeFormatter.string(from: tDate)) >> \(dateTimeFormatter.string(from: cDate))")
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
            print("Restored: \(dateTimeFormatter.string(from: tDate)) >> \(dateTimeFormatter.string(from: cDate))")
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

