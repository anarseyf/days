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

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!

    // MARK: - User Actions

    @IBAction func resetButton(_ sender: UIButton) {
        loopTimer?.invalidate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsViewController")
        if let settingsViewController = viewController as? SettingsViewController {
            settingsViewController.model = model
            navigationController?.modalPresentationStyle = .overCurrentContext
            navigationController?.present(settingsViewController, animated: true)
        }
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
        settingsButton.alpha = 0.6 // TODO - replace image and remove

        navigationItem.hidesBackButton = true
        // TODO - fold into state setter
        mainLabel.text = ""
        titleLabel.text = model!.title
        startLoopTimer()
    }

    func configureProgressView() {
        if let progressVC = children.first as? ProgressViewController {
            progressVC.model = model
        }
    }

    func startLoopTimer() {

        func loopHandler(timer: Timer?) -> Void {

            guard let model = model else {
                print("Loop: No model")
                return
            }

            let state = model.state

            let formatter = Utils.shared.intervalFormatter
            
            // Main view
            switch state {
            case .invalid:
                print("Loop: Invalid state")
            case .willRun:
                mainLabel.text = Utils.daysString(from: model.totalDays!)
                let outsideString = formatter.string(from: model.outsideInterval!) ?? "-"
                secondaryLabel.text = "starts in \(outsideString)"
            case .running:
                mainLabel.text = "Day \(model.currentDay!)"
                let daysString = Utils.daysString(from: model.remainingDays!)
                secondaryLabel.text = "\(daysString) left of \(model.totalDays!)"
            case .ended:
                let daysString = Utils.daysString(from: model.totalDays!)
                mainLabel.text = "\(daysString)\ndone"
                let outsideString = formatter.string(from: model.outsideInterval!) ?? "-"
                secondaryLabel.text = "ended \(outsideString) ago" // TODO - move into Details View
            }
        }
        loopTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: loopHandler)

        loopHandler(timer: loopTimer) // Otherwise it takes a second for the views to update // TODO - review if still needed
    }
}
