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
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var detailsStartLabel: UILabel!
    @IBOutlet weak var detailsTargetLabel: UILabel!
    @IBOutlet weak var detailsRemainingIntervalLabel: UILabel!
    @IBOutlet weak var detailsView: UIStackView!
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
        mainLabel.text = ""
        detailsRemainingIntervalLabel.text = ""
        titleLabel.text = model!.title
        updateDetailsLabels()
        startLoopTimer()
    }

    func configureProgressView() {
        if let progressVC = children.first as? ProgressViewController {
            progressVC.model = model
        }
    }

    func updateDetailsLabels() {
        detailsStartLabel.text = (model?.startDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.startDate!))
        detailsTargetLabel.text = (model?.targetDate == nil ? "-" : Utils.shared.dateTimeFormatter.string(from: model!.targetDate!))
    }

    func startLoopTimer() {

        func loopHandler(timer: Timer?) -> Void {

            guard let model = model else {
                print("Loop: No model")
                return
            }

            let state = model.state
            titleLabel.text = state.rawValue // TODO - remove

            let formatter = Utils.shared.intervalFormatter

            // Main view
            switch state {
            case .invalid:
                print("Loop: Invalid state")
            case .willRun:
                mainLabel.text = "\(model.totalDays!) days"
                let outsideString = formatter.string(from: model.outsideInterval!) ?? "-"
                secondaryLabel.text = "Starts in \(outsideString)"
            case .running:
                mainLabel.text = "Day \(model.completedDays!)"
                secondaryLabel.text = "\(model.remainingDays!) days left of \(model.totalDays!)"
            case .ended:
                mainLabel.text = "\(model.totalDays!) days\ndone"
                let outsideString = formatter.string(from: model.outsideInterval!) ?? "-"
                secondaryLabel.text = "Ended \(outsideString) ago"
            }

            // Details view
            switch state {
            case .invalid:
                detailsRemainingIntervalLabel.text = "invalid"
            case .willRun:
                fallthrough
            case .running:
                detailsRemainingIntervalLabel.text = formatter.string(from: model.remainingInterval!)
            case .ended:
                detailsRemainingIntervalLabel.text = "-"
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)

        loopHandler(timer: nil) // otherwise it takes a second for the views to update
    }
}
