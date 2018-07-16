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

    @IBOutlet weak var remainingIntervalLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!

    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        rescheduleNotification()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame

        self.view.insertSubview(blurEffectView, at: 0)

        remainingIntervalLabel.text = ""
        updateDetailsLabels()
    }

    func updateDetailsLabels() {
        startLabel.text = (model?.startDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.startDate!))
        targetLabel.text = (model?.targetDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.targetDate!))
    }

    func rescheduleNotification() {
        guard let model = model else { return }

        let notificationDate = Utils.notificationDate(fromTarget: model.targetDate!,
                                                      withTimeOverride: timePicker.date)

        NotificationsHandler.reset()
        NotificationsHandler.schedule(on: notificationDate, with: model)
    }

    func loop() {

        let formatter = Utils.shared.intervalFormatter

        switch model!.state {
        case .invalid:
            remainingIntervalLabel.text = "invalid"
        case .willRun:
            fallthrough
        case .running:
            remainingIntervalLabel.text = formatter.string(from: model!.remainingInterval!)
        case .ended:
            remainingIntervalLabel.text = "-"
        }
    }
}
