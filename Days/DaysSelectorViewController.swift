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

    var model = TimerModel()
    var calendar: CalendarViewController?
    var isCalendarShown: Bool {
        get {
            return (calendar == nil ? false : !calendar!.view.isHidden)
        }
        set(newValue) {
            calendar?.view.isHidden = !newValue
        }
    }
    var calendarStartDates: [Date]?
    let numMonthsBack = 1 // TODO -1...11
    let numMonthsForward = 1
    let startControlsTopMarginDefault: CGFloat = 50.0
    let startControlsTopMarginCompact: CGFloat = 0.0
    let daysInputTopMarginDefault: CGFloat = 50.0
    let daysInputTopMarginCompact: CGFloat = 20.0

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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var minusDayButton: UIButton!
    @IBOutlet weak var plusDayButton: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startControlsView: UIView!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var startControlsTopMargin: NSLayoutConstraint!
    @IBOutlet weak var daysInputTopMargin: NSLayoutConstraint!

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

    @IBAction func leftArrow(_ sender: UIButton) {
        setStartDate(Utils.adjustedDate(model.startDate!, by: -1))
    }

    @IBAction func rightArrow(_ sender: UIButton) {
        setStartDate(Utils.adjustedDate(model.startDate!, by: 1))
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

    @objc func calendarLabelTapped(_ sender: UITapGestureRecognizer) {

        if !isCalendarShown {
            UIView.animate(withDuration: 0.4,
                animations: {
                    self.daysInputTopMargin.constant = self.daysInputTopMarginCompact
                    self.startControlsTopMargin.constant = self.startControlsTopMarginCompact
                    self.view.layoutIfNeeded() }, // TODO - setNeedsLayout?
                completion: { finished in
                    self.configureCalendar()
                    self.isCalendarShown = true
            })
        }
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true

        daysInput.delegate = self
        UNUserNotificationCenter.current().delegate = self

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(calendarLabelTapped(_:)))
        calendarLabel.addGestureRecognizer(recognizer)

        resetUI()
        restore()
    }

    func configureCalendar() {
        if let calendarViewController = children.first as? CalendarViewController {

            calendarViewController.calendarDelegate = self

            var components = Utils.componentsFromDate(Utils.monthStart(from: Date()))
            calendarStartDates = Array(-numMonthsBack...numMonthsForward).map { index -> Date in
                var currentComponents = components
                currentComponents.month = components.month! + index
                return currentComponents.date!
            }

            calendar = calendarViewController
            updateCalendarModel()
        }
    }

    func updateCalendarModel() {
        guard let dates = calendarStartDates else { return }
        calendar?.model = CalendarModel(monthStartDates: dates,
                                        currentMonthStartDate: dates[numMonthsBack],
                                        selectedDate: model.startDate)
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

    func setStartDate(_ date: Date?) {
        model.startDate = date
        updateTargetDate()
        updateCalendarModel()
        updateCalendarLabel()
    }

    private func updateTargetDate() {
        model.targetDate = Date(timeInterval: selectedInterval, since: model.startDate!)
    }

    func updateCalendarLabel() {
        let title = Utils.shared.dateOnlyFormatter.string(from: model.startDate!)

        // TODO - Today/Tomorrow/Yesterday
        /*
         let formatter = DateFormatter()
         formatter.dateFormat = "EE, MMM d"
         let nowComponents = Utils.componentsFromDate(Date())
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
         */
        calendarLabel.text = title
    }

    private func resetUI() {
        startToday()
        setNumDays(1)
        isCalendarShown = false
        resetConstraints()
        NotificationsHandler.reset()
    }

    func resetConstraints() {
        startControlsTopMargin.constant = startControlsTopMarginDefault
        daysInputTopMargin.constant = daysInputTopMarginDefault
    }

    private func restore() {
        let restoredModel = TimerModel.restore()
        if (restoredModel != nil) {
            model = restoredModel!
            presentCountdown()
        }
    }

    private func startToday() {
        let today = Utils.dateFloor(from: Date())
        setStartDate(today)
    }
}
