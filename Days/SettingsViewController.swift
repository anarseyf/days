//
//  SettingsViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Properties

    var model: TimerModel?

    // MARK: - IBOutlets

    @IBOutlet weak var totalDaysLabel: UILabel!
    @IBOutlet weak var startsOnLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endsOnLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var notifySwitch: UISwitch!

    // MARK: - IBActions

    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        updateNotificationDate()
        scheduleNotification()
        updateNotifyUI()
    }

    @IBAction func notifyToggled(_ sender: UISwitch) {
        guard let model = model else { return }

        if (sender.isOn) {
            updateNotificationDate()
        }
        else {
            model.notificationDate = nil
        }

        scheduleNotification()
        model.save()
        updateNotifyUI()
    }

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame

        self.view.insertSubview(blurEffectView, at: 0)

        updateLabels()
        updateNotifyUI()
    }

    private func updateNotificationDate() {
        guard let model = model else { return }

        model.notificationDate = Utils.notificationDate(fromTarget: model.targetDate!,
                                                        withTimeOverride: timePicker.date)
    }

    private func updateNotifyUI() {
        if let date = model?.notificationDate {
            let formatter = Utils.shared.dateNoYearFormatter
            notifyLabel.text = "Notify on \(formatter.string(from: date)) at:"
            notifySwitch.isOn = true
            timePicker.isHidden = false
            timePicker.date = date
        }
        else {
            notifyLabel.text = "Notification off"
            notifySwitch.isOn = false
            timePicker.isHidden = true
        }
    }

    private func updateLabels() {
        guard let model = model else { return }

        startDateLabel.text = Utils.shared.dateOnlyFormatter.string(from: model.startDate!)

        var lastDayComponents = Calendar.current.dateComponents(in: .current, from: model.targetDate!)
        lastDayComponents.second = -1
        endDateLabel.text = Utils.shared.dateNoYearFormatter.string(from: lastDayComponents.date!)

        switch model.state {
        case .invalid:
            totalDaysLabel.text = ""
        case .willRun, .running, .ended:
            totalDaysLabel.text = Utils.daysString(from: model.totalDays!, withNumber: true)
        }

        switch model.state {
        case .invalid:
            break
        case .willRun:
            startsOnLabel.text = "Starts on:"
            endsOnLabel.text = "Ends on:"
        case .running:
            startsOnLabel.text = "Started on:"
            endsOnLabel.text = "Ends on:"
        case .ended:
            startsOnLabel.text = "Started on:"
            endsOnLabel.text = "Ended on:"
        }
    }

    private func unscheduleExisting() {
        NotificationsHandler.reset()
    }

    private func scheduleNotification() {
        guard let model = model else { return }

        unscheduleExisting()

        if let date = model.notificationDate {
            NotificationsHandler.schedule(on: date, with: model)
        }
    }
}
