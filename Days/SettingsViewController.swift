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
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        rescheduleNotification()
        updateNotifyLabel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame

        self.view.insertSubview(blurEffectView, at: 0)

        updateDetailsLabels()
        updateNotifyLabel()

        if let date = model?.notificationDate {
            timePicker.date = date
        }

        startLoopTimer()
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            loopTimer?.invalidate()
        }
    }

    func updateNotifyLabel() {
        if let date = model?.notificationDate {
            let formatter = Utils.shared.dateOnlyFormatter
            notifyLabel.text = "Notify on \(formatter.string(from: date)) at:"
        }
    }

    func updateDetailsLabels() {
        startLabel.text = (model?.startDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.startDate!))
        targetLabel.text = (model?.targetDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.targetDate!))
    }

    func rescheduleNotification() {
        guard let model = model else { return }

        let notificationDate = Utils.notificationDate(fromTarget: model.targetDate!,
                                                      withTimeOverride: timePicker.date)

        model.notificationDate = notificationDate
        NotificationsHandler.reset()
        NotificationsHandler.schedule(on: notificationDate, with: model)
    }

    func startLoopTimer() {

        func loopHandler(timer: Timer?) -> Void {
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
