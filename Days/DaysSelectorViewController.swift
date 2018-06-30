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
    let defaultInterval = 3.0 // TODO - remove, used for testing only
    let userDefaultsKeyTargetDate = "targetDate"
    let userDefaultsKeyCreatedDate = "createdDate"

    var dateOnlyFormatter = DateFormatter()
    var timeOnlyFormatter = DateFormatter()
    var dateTimeFormatter = DateFormatter()
    var intervalFormatter = DateComponentsFormatter()
    var loopTimer: Timer? = nil
    var days = Array(0...100)

    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let date = Date(timeIntervalSinceNow: selectedInterval)
            targetDateLabel.text = dateTimeFormatter.string(from: date) // TODO - need another (always-visible) label for this
        }
    }
    
    var showDetails: Bool = false {
        didSet {
            detailsView.isHidden = !showDetails
            let title = (showDetails ? "hide" : "show details")
            toggleButton.setTitle(title, for: .normal)
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var detailsView: UIStackView!

    @IBOutlet weak var expiresInLabel: UILabel!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!

    // MARK: - User action handlers

    @IBAction func startButton(_ sender: UIButton) {
        let createdDate = Date()
        let targetDate = Date(timeIntervalSinceNow: selectedInterval)

//        var components = Calendar.current.dateComponents(in: TimeZone.current, from: targetDate)
//        print("\(components.hour?.description ?? "-") h, \(components.minute?.description ?? "-") m")
//        components.hour = 23 // TODO
//        components.minute = 59
//        components.second = 59
//        targetDate = components.date

        setTargetDate(targetDate, createdOn: createdDate)
        setModelState(.running)
        scheduleNotification(after: selectedInterval)
    }

    @IBAction func resetButton(_ sender: UIButton) {
        setModelState(.notStarted)
        setTargetDate(nil)
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
        dateTimeFormatter.timeStyle = .short

        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .abbreviated

        // TODO - fold into state setter
        dayLabel.text = ""
        remainingLabel.text = ""

        showDetails = false

        selectedInterval = defaultInterval

        setModelState(.notStarted)

        startLoopTimer()
        restore()
    }

    func setModelState(_ state: TimerModel.State) {
        model.state = state
        updateUI()
    }

    func setTargetDate(_ targetDate: Date?, createdOn createdDate: Date? = nil) {
        model.targetDate = targetDate
        model.createdDate = createdDate
        createdDateLabel.text = (createdDate == nil ? "-" : dateTimeFormatter.string(from: createdDate!))
        save()
    }

    func updateUI() {
        stateLabel.text = model.state.rawValue

        switch model.state {
        case .notStarted:
            dayLabel.isHidden = true
            remainingLabel.isHidden = true
            resetButton.isHidden = true
            toggleButton.isHidden = true
            startButton.isHidden = false
            picker.isHidden = false
            remainingLabel.text = ""
            showDetails = false
        case .running:
            picker.isHidden = true
            startButton.isHidden = true
            resetButton.isHidden = false
            dayLabel.isHidden = false
            remainingLabel.isHidden = false
            toggleButton.isHidden = false
        case .done:
            break
        }
    }

    func startLoopTimer() {

        func loopHandler(t: Timer) -> Void {
            if let date = model.targetDate {
                let remainingInterval = date.timeIntervalSinceNow
                let remainingSeconds = Int(remainingInterval)
                let remainingDays = remainingSeconds / secondsPerDay + 1
                let isDone = remainingSeconds < 0
                let elapsedSeconds = -1 * Int(model.createdDate!.timeIntervalSinceNow)
                let elapsedDays = (elapsedSeconds / secondsPerDay) + 1 // TODO - prevent overrun if we're past targetDate

                if (isDone) {
                    dayLabel.text = ""
                    remainingLabel.text = "TIMER DONE"
                    setModelState(.done)
                    setTargetDate(nil)
                }
                else {
                    dayLabel.text = "DAY\n\(elapsedDays)"
                    expiresInLabel.text = intervalFormatter.string(from: remainingInterval)!
                    remainingLabel.text = "\(remainingDays) \(remainingDays == 1 ? "DAY" : "DAYS" ) LEFT"
                }
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)
    }

    func save() {
        let defaults = UserDefaults.standard

        if (model.targetDate == nil) {
            print("Removing")
            defaults.removeObject(forKey: userDefaultsKeyTargetDate)
            defaults.removeObject(forKey: userDefaultsKeyCreatedDate)
        }
        else {
            let tDate = model.targetDate!
            let cDate = model.createdDate!
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
            model.createdDate = cDate
            model.targetDate = tDate
            setModelState(.running)
        }
    }
    
    func titleForRow(_ row: Int) -> String {
        return String(days[row])
    }

    func scheduleNotification(after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Timer done"
        content.body = "Now what?"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) {
            (error) in
            print ("Notification scheduled\(error != nil ? " WITH ERRORS" : "").")
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

