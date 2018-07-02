//
//  CountdownViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {

    var model: TimerModel?
    var loopTimer: Timer? = nil
    var dismissHandler: (() -> Void)?

    var showDetails: Bool = false {
        didSet {
            detailsView.isHidden = !showDetails
            let title = (showDetails ? "hide" : "show details")
            toggleButton.setTitle(title, for: .normal)
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var detailsView: UIStackView!
    @IBOutlet weak var expiresInLabel: UILabel!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!

    @IBAction func toggleButton(_ sender: UIButton) {
        showDetails = !showDetails
    }

    @IBAction func resetButton(_ sender: UIButton) {
        setModelState(.notStarted)
        model!.setTargetDate(nil)
        dismiss(animated: true, completion: dismissHandler)
    }

    override func willMove(toParent parent: UIViewController?) {
        print("WILL MOVE") // TODO
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(model != nil, "Model must be set when presenting the Countdown view controller")

        // TODO - fold into state setter
        dayLabel.text = ""
        remainingLabel.text = ""
        titleLabel.text = model!.title

        startLoopTimer()
    }

    func setModelState(_ state: TimerModel.State) { // TODO - computed property
        model?.state = state
    }

    func updateTimerLabels() {
        createdDateLabel.text = (model?.createdDate != nil ? Utils.shared.dateTimeFormatter.string(from: model!.createdDate!) : "-")
        targetDateLabel.text = (model?.targetDate != nil ? Utils.shared.dateTimeFormatter.string(from: model!.targetDate!) : "-")
    }

    func startLoopTimer() {

        func loopHandler(t: Timer) -> Void {
            if let date = model?.targetDate {
                let remainingInterval = date.timeIntervalSinceNow
                let remainingSeconds = Int(remainingInterval)
                let remainingDays = remainingSeconds / Utils.shared.secondsPerDay + 1
                let isDone = remainingSeconds < 0
                let elapsedSeconds = -1 * Int(model!.createdDate!.timeIntervalSinceNow)
                let elapsedDays = (elapsedSeconds / Utils.shared.secondsPerDay) + 1 // TODO - prevent overrun if we're past targetDate

                if (isDone) {
                    dayLabel.text = ""
                    expiresInLabel.text = "-"
                    remainingLabel.text = "TIMER DONE"
                    setModelState(.done)
                }
                else {
                    dayLabel.text = "DAY\n\(elapsedDays)"
                    expiresInLabel.text = Utils.shared.intervalFormatter.string(from: remainingInterval)!
                    remainingLabel.text = "\(remainingDays) \(remainingDays == 1 ? "DAY" : "DAYS" ) LEFT"
                }
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)
    }
}
