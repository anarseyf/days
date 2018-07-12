//
//  CountdownViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {

    // MARK: - Properties

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

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var detailsView: UIStackView!
    @IBOutlet weak var expiresInLabel: UILabel!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!

    // MARK: - User Actions

    @IBAction func toggleButton(_ sender: UIButton) {
        showDetails = !showDetails
    }

    @IBAction func resetButton(_ sender: UIButton) {
        loopTimer?.invalidate()
        navigationController?.popViewController(animated: true)
    }

    override func willMove(toParent parent: UIViewController?) {
        if (parent == nil) { // popped off the nav stack
            dismissHandler?()
        }
    }

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(model != nil, "Model must be set when presenting the Countdown view controller")

        configureProgressView()

        navigationItem.hidesBackButton = true
        // TODO - fold into state setter
        dayLabel.text = ""
        remainingLabel.text = ""
        titleLabel.text = model!.title
        updateTimerLabels()
        startLoopTimer()
    }

    func configureProgressView() {
        if let progressVC = children.first as? ProgressViewController {
            progressVC.model = model
        }
    }

    func setModelState(_ state: TimerModel.State) { // TODO - computed property
        model?.state = state
    }

    func updateTimerLabels() {
        startDateLabel.text = (model?.startDate != nil ? Utils.shared.dateTimeFormatter.string(from: model!.startDate!) : "-")
        targetDateLabel.text = (model?.targetDate != nil ? Utils.shared.dateTimeFormatter.string(from: model!.targetDate!) : "-")
    }

    func startLoopTimer() {

        func loopHandler(timer: Timer?) -> Void {

            if let date = model?.targetDate {
                let remainingInterval = date.timeIntervalSinceNow
                let remainingSeconds = Int(remainingInterval)
                let remainingDays = remainingSeconds / Utils.secondsPerDay + 1
                let isDone = remainingSeconds < 0
                let elapsedSeconds = -1 * Int(model!.startDate!.timeIntervalSinceNow)
                let elapsedDays = (elapsedSeconds / Utils.secondsPerDay) + 1 // TODO - prevent overrun if we're past targetDate

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

        loopHandler(timer: nil) // otherwise it takes a second for the views to update
    }
}
