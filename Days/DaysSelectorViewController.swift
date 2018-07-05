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
            updateProvisionalUI()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var provisionalDateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        titleInput.delegate = self
        UNUserNotificationCenter.current().delegate = self

        let now = Date()
        startDatePicker.minimumDate = now - Utils.startDateBracket
        startDatePicker.maximumDate = now + Utils.startDateBracket
        print("Min: \(String(describing: startDatePicker.minimumDate!)), Max: \(String(describing: startDatePicker.maximumDate!))")

        selectedInterval = 0
        reset()
        restore()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CountdownViewController {
            prepareForPresenting(viewController)
        }
    }

    private func prepareForPresenting(_ viewController: CountdownViewController) {
        viewController.model = model
        viewController.dismissHandler = { () in
            self.reset()
            self.save()
        }
    }

    func setModelState(_ state: TimerModel.State) {
        model.state = state
    }

    func updateTargetDate() {
        let targetDate = Date(timeInterval: selectedInterval, since: model.createdDate!)
        model.targetDate = targetDate
    }

    func updateProvisionalUI() {

        let formatter = Utils.shared.dateTimeFormatter
        let createdString = (model.createdDate == nil ? "-" : formatter.string(from: model.createdDate!))
        let targetString = (model.createdDate == nil ? "-" : formatter.string(from: model.targetDate!))

        provisionalDateLabel.text = "\(createdString)\n\(targetString)"

        if (model.targetDate != nil) {
            let isPast = (model.targetDate! < Date())
            startButton.isHidden = isPast
            provisionalDateLabel.textColor = (isPast ? UIColor.red : UIColor.darkText)
        }
    }

    func reset() {
        print("RESET")

        setModelState(.notStarted)
        model.targetDate = nil
        model.createdDate = nil
        model.title = nil
        titleInput.text = "" // TODO - do this in view update methods

        picker.selectRow(0, inComponent: 0, animated: true)
        startDatePicker.setDate(Date(), animated: true)

        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        UIApplication.shared.applicationIconBadgeNumber = 0
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
            print("Restored: \(model)")

            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countdownViewController")
            if let countdownViewController = viewController as? CountdownViewController {
                prepareForPresenting(countdownViewController)
                navigationController?.pushViewController(countdownViewController, animated: false)
            }
        }
        else {
            print("Nothing restored")
        }
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
        return String(days[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval = Double(row * Utils.secondsPerDay)

        let createdDate = model.createdDate ?? Date()
        model.createdDate = createdDate

        updateTargetDate()
        updateProvisionalUI()
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

    // MARK: - User action handlers

    @IBAction func startDateAdjusted(_ sender: UIDatePicker) {
        print("Start Date: \(Utils.shared.dateTimeFormatter.string(from: startDatePicker.date))")

        model.createdDate = startDatePicker.date
        updateTargetDate()
        updateProvisionalUI()
    }

    @IBAction func startButton(_ sender: UIButton) {
        save()
        setModelState(.running)
        scheduleNotification(after: selectedInterval)
    }
}

