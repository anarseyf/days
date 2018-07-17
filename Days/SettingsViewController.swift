//
//  SettingsViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var model: TimerModel?
    var loopTimer: Timer? = nil

    @IBOutlet weak var remainingIntervalLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var notifySwitch: UISwitch!

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

    private func updateNotificationDate() {
        guard let model = model else { return }

        model.notificationDate = Utils.notificationDate(fromTarget: model.targetDate!,
                                                        withTimeOverride: timePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame

        self.view.insertSubview(blurEffectView, at: 0)

        updateLabels()
        updateNotifyUI()

        startLoopTimer()
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            loopTimer?.invalidate()
        }
    }

    func updateNotifyUI() {
        if let date = model?.notificationDate {
            let formatter = Utils.shared.dateOnlyFormatter
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

    func updateLabels() {
        guard let model = model else { return }

        let formatter = Utils.shared.dateOnlyFormatter

        startLabel.text = formatter.string(from: model.startDate!)

        var lastDayComponents = Calendar.current.dateComponents(in: .current, from: model.targetDate!)
        lastDayComponents.second = -1
        targetLabel.text = formatter.string(from: lastDayComponents.date!)
    }

    func unscheduleExisting() {
        NotificationsHandler.reset()
    }

    func scheduleNotification() {
        guard let model = model else { return }

        unscheduleExisting()

        if let date = model.notificationDate {
            NotificationsHandler.schedule(on: date, with: model)
        }
    }

    func startLoopTimer() {

        func loopHandler(timer: Timer?) -> Void {
//            print("Settings loop")

            let formatter = Utils.shared.intervalFormatter

            switch model!.state {
            case .invalid:
                remainingIntervalLabel.text = "(invalid)"
            case .willRun:
                remainingIntervalLabel.text = "(not started)"
            case .running:
                remainingIntervalLabel.text = formatter.string(from: model!.remainingInterval!)
            case .ended:
                remainingIntervalLabel.text = "(ended)"
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)

        loopHandler(timer: loopTimer)
    }
}
