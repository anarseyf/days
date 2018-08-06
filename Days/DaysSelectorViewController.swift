//
//  ViewController.swift
//  Days
//
//  Created by Anar Seyf on 6/28/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

struct StartOption {
    let date: Date // TODO - use offset, not Date(). Otherwise the date becomes stale
    let title: String
}

class DaysSelectorViewController: UIViewController {

    // MARK: - Properties

    let startOffsetPast = -7
    let startOffsetFuture = 7
    let arrowButtonWidth: CGFloat = 50.0
    var startOptions: [StartOption] = []
    var selectedStartOptionIndex = 0
    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            if (model.startDate == nil) {
                model.startDate = Date()
            }
            updateTargetDate()
        }
    }

    var selectedNumDays: Int {
        get {
            return Int(selectedInterval / Double(Utils.secondsPerDay))
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var daysInput: UITextField!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var minusDayButton: UIButton!
    @IBOutlet weak var plusDayButton: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startControlsView: UIView!

    // MARK: - User action handlers

    @IBAction func minusDayButton(_ sender: UIButton) {
        let numDays = selectedNumDays
        if (numDays > Utils.minDays) {
            setNumDays(numDays - 1)
        }
    }
    
    @IBAction func plusDayButton(_ sender: UIButton) {
        let numDays = selectedNumDays
        if (numDays < Utils.maxDays) {
            setNumDays(numDays + 1)
        }
    }

    @IBAction func doneButton(_ sender: UIButton) {
        daysInput.resignFirstResponder()
        setDoneButtonHidden(true)
    }

    @IBAction func previousStartOptionButton(_ sender: UIButton) {
        if (selectedStartOptionIndex > 0) {
            selectStartOption(selectedStartOptionIndex - 1)
        }
    }

    @IBAction func nextStartOptionButton(_ sender: UIButton) {
        if (selectedStartOptionIndex < startOptions.count - 1) {
            selectStartOption(selectedStartOptionIndex + 1)
        }
    }

    @IBAction func startButton(_ sender: UIButton) {

        if (model.state == .invalid) {
            print("Invalid model")
            return
        }

        model.isActive = true
        let notificationDate = Utils.notificationDate(fromTarget: model.targetDate!)
        let now = Date()
        NotificationsHandler.reset()
        if now < notificationDate {
            model.notificationDate = notificationDate
            NotificationsHandler.schedule(on: notificationDate, with: model)
        }
        model.save()
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true

        daysInput.delegate = self
        scrollView.delegate = self
        UNUserNotificationCenter.current().delegate = self

        createStartOptions()
        configureScrollView()

        resetUI()
        restore()
    }

    func createStartOptions() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, MMM d"
        let now = Date()
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents(in: .current, from: now)
        let day = nowComponents.day!

        func replaceTitle(_ title: String, forOffset offset: Int) -> String {
            switch (offset) {
            case -1: return "YESTERDAY"
            case 0: return "TODAY"
            case 1: return "TOMORROW"
            default: return title
            }
        }

        startOptions = Array(startOffsetPast...startOffsetFuture).map { i in
            var components = nowComponents
            components.day = day + i
            let date = components.date!
            let title = replaceTitle(formatter.string(from: date), forOffset: i)
            return StartOption(date: date, title: title)
        }
    }

    private func configureScrollView() {

        let frameSize = CGSize(width: scrollView.frame.size.width,
                               height: scrollView.frame.size.height)

        for (index, element) in startOptions.enumerated() {
            let origin = CGPoint(x: frameSize.width * CGFloat(index), y: 0)
            let label = UILabel(frame: CGRect(origin: origin, size: frameSize))
            label.text = element.title
            label.font = UIFont.systemFont(ofSize: 30.0)
            label.textAlignment = .center

            scrollView.addSubview(label)
        }

        scrollView.contentSize = CGSize(width: frameSize.width * CGFloat(startOptions.count),
                                        height: frameSize.height)
        scrollView.isPagingEnabled = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapRecognizer)
    }

    @objc func scrollViewTap(_ sender: UITapGestureRecognizer) {
        setStartOptionToday()
    }

    func setIncrementButtonsHidden(_ isHidden: Bool) {
        minusDayButton.isHidden = isHidden
        plusDayButton.isHidden = isHidden
    }

    func setDoneButtonHidden(_ isHidden: Bool) {
        doneButton.isHidden = isHidden
        startControlsView.isHidden = !isHidden
        startButton.isHidden = !isHidden
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CountdownViewController {
            prepareForPresenting(viewController)
        }
    }

    private func prepareForPresenting(_ viewController: CountdownViewController) {
        viewController.model = model
        viewController.dismissHandler = { () in
            self.model.reset()
            self.model.save()
            self.resetUI()
        }
    }

    private func presentCountdown() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countdownViewController")
        if let countdownViewController = viewController as? CountdownViewController {
            prepareForPresenting(countdownViewController)
            navigationController?.pushViewController(countdownViewController, animated: false)
        }
    }

    func setNumDays(_ numDays: Int) {
        daysInput.text = String(numDays)
        daysLabel.text = Utils.daysString(from: numDays, withNumber: false)
        minusDayButton.isHidden = (numDays <= Utils.minDays) // TODO - use this in updateIncrementButtons(withHidden_:)
        plusDayButton.isHidden = (numDays >= Utils.maxDays)
        selectedInterval = Double(numDays * Utils.secondsPerDay)
    }

    func selectStartOption(_ index: Int, animated: Bool = false) {

        selectedStartOptionIndex = index

        let option = startOptions[index]
        let adjusted = TimerModel.dateFloor(from: option.date)
        model.startDate = adjusted
        updateTargetDate()

        updateScrollView()
    }

    private func updateTargetDate() {
        model.targetDate = Date(timeInterval: selectedInterval, since: model.startDate!)
    }

    func updateScrollView() {
        let size = scrollView.contentSize
        let itemWidth = CGFloat(size.width) / CGFloat(startOptions.count)
        let offset = CGPoint(x: itemWidth * CGFloat(selectedStartOptionIndex), y: 0)
        scrollView.setContentOffset(offset, animated: true)

        leftArrow.isHidden = (selectedStartOptionIndex <= 0)
        rightArrow.isHidden = (selectedStartOptionIndex >= startOptions.count - 1)
    }

    private func resetUI() {
        setStartOptionToday()
        setNumDays(1)
        NotificationsHandler.reset()
    }

    private func restore() {
        let restoredModel = TimerModel.restore()
        if (restoredModel != nil) {
            model = restoredModel!
            presentCountdown()
        }
    }

    private func setStartOptionToday() {
        selectStartOption(-startOffsetPast)
    }
}

