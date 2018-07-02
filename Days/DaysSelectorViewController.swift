//
//  ViewController.swift
//  Days
//
//  Created by Anar Seyf on 6/28/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

class DaysSelectorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UNUserNotificationCenterDelegate, UITextFieldDelegate {

    // MARK: - Properties

    let notificationDelay = 3.0
    let userDefaultsKey = "timerModel"
    let days = Array(0...100)
    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let date = Date(timeIntervalSinceNow: selectedInterval)
            provisionalDateLabel.text = "Timer will expire on\n\(Utils.shared.dateTimeFormatter.string(from: date))"
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var provisionalDateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleInput: UITextField!

    // MARK: - User action handlers

    @IBAction func startButton(_ sender: UIButton) {
        let createdDate = Date()
        let targetDate = Date(timeIntervalSinceNow: selectedInterval)

        // TODO - uncomment to adjust time:
        //        var components = Calendar.current.dateComponents(in: TimeZone.current, from: targetDate)
        //        print("\(components.hour?.description ?? "-") h, \(components.minute?.description ?? "-") m")
        //        components.hour = 23 // TODO
        //        components.minute = 59
        //        components.second = 59
        //        targetDate = components.date

        model.setTargetDate(targetDate, createdOn: createdDate)
        save()
        setModelState(.running)
        scheduleNotification(after: selectedInterval)
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        titleInput.delegate = self
        UNUserNotificationCenter.current().delegate = self

        reset()
        selectedInterval = 0
        picker.selectRow(0, inComponent: 0, animated: false)
        restore()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CountdownViewController {
            viewController.model = model
            viewController.dismissHandler = { () in
                self.reset()
                self.save()
            }
        }
    }

    func reset() {
        setModelState(.notStarted)
        model.setTargetDate(nil)
        model.title = nil
        titleInput.text = ""

        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    func setModelState(_ state: TimerModel.State) {
        model.state = state
        stateLabel.text = model.state.rawValue // TODO - not always updated
    }

    func save() {
        let defaults = UserDefaults.standard
        if (model.targetDate == nil) {
            print("Removing")
            defaults.removeObject(forKey: userDefaultsKey)
        }
        else {
            let tDate = model.targetDate!
            let cDate = model.createdDate!
            print("Saving: \(Utils.shared.dateTimeFormatter.string(from: tDate)) >> \(Utils.shared.dateTimeFormatter.string(from: cDate))")

            let encoded = NSKeyedArchiver.archivedData(withRootObject: model)
            defaults.set(encoded, forKey: userDefaultsKey)
        }
    }

    func restore() {
        let defaults = UserDefaults.standard
        if let encoded = defaults.data(forKey: userDefaultsKey),
            let restoredModel = NSKeyedUnarchiver.unarchiveObject(with: encoded) as? TimerModel {
            model = restoredModel
            setModelState(.running) // TODO - computed property?
            titleInput.text = model.title
            print("Restored: \(model)")

            // TODO - present CountdownVC, no animation
        }
        else {
            print("Nothing restored")
        }
    }
    
    func titleForRow(_ row: Int) -> String {
        return String(days[row])
    }

    func scheduleNotification(after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = model.title ?? "Timer expired"
        content.body = (model.targetDate == nil ? "" : Utils.shared.dateTimeFormatter.string(from: model.targetDate!))
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (interval + notificationDelay), repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
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
        selectedInterval = Double(row * Utils.shared.secondsPerDay)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge])
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // TODO - disable Start and re-enable in didEndEditing
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        model.title = textField.text
    }
}

