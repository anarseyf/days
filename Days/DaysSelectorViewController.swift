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
    let days = Array(1...365)
    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let createdDate = model.createdDate ?? Date()
            model.createdDate = createdDate

            updateTargetDate()

            updateProvisionalUI()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var provisionalDateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var todayButton: UIButton!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        picker.delegate = self
        picker.dataSource = self
        titleInput.delegate = self
        UNUserNotificationCenter.current().delegate = self

        let now = Date()
        startDatePicker.minimumDate = now - Utils.startDateBracket
        startDatePicker.maximumDate = now + Utils.startDateBracket
        print("Min: \(String(describing: startDatePicker.minimumDate!)), Max: \(String(describing: startDatePicker.maximumDate!))")

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

    func selectDaysIndex(_ row: Int) {
        let numDays = days[row]
        selectedInterval = Double(numDays * Utils.secondsPerDay)
//        picker.selectRow(row, inComponent: 0, animated: true) // TODO - loop?
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
        let targetString = (model.createdDate == nil ? "-" : formatter.string(from: model.targetDate!))

        provisionalDateLabel.text = targetString

        if (model.targetDate != nil) {
            let isPast = (model.targetDate! < Date())
//            startButton.isHidden = isPast
            provisionalDateLabel.textColor = (isPast ? UIColor.red : UIColor.darkText)
        }
    }

    func reset() {
        print("RESET")

        // State, models
        setModelState(.notStarted)
        selectDaysIndex(0)

        model.targetDate = nil
        model.createdDate = nil
        model.title = nil

        // UI
        titleInput.text = "" // TODO - do this in view update methods

        startDatePicker.setDate(Date(), animated: true)

        todayButton.isHidden = false
        startDatePicker.isHidden = true

        updateProvisionalUI()

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

            presentCountdownIfNeeded()
        }
        else {
            print("Nothing restored")
        }
    }

    func presentCountdownIfNeeded() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countdownViewController")
        if let countdownViewController = viewController as? CountdownViewController {
            prepareForPresenting(countdownViewController)
            navigationController?.pushViewController(countdownViewController, animated: false)
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
        let value = days[row]
        return String(value) + (value == 1 ? " day" : " days")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectDaysIndex(row)
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

    @IBAction func todayButton(_ sender: UIButton) {
        sender.isHidden = true
        startDatePicker.isHidden = false
    }

    @IBAction func resetButton(_ sender: UIButton) {
        reset()
        save()
    }

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

