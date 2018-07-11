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
    let date: Date
    let title: String
}

class DaysSelectorViewController: UIViewController {

    // MARK: - Properties

    let notificationDelay = 3.0
    let userDefaultsKey = "timerModel"
    let startOffsetPast = -3
    let startOffsetFuture = 7
    var startOptions: [StartOption] = []
    var selectedStartOptionIndex = 0
    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let startDate = model.startDate ?? Date()
            model.startDate = startDate
            updateTargetDate()
            updateProvisionalUI()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var provisionalDateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var daysInput: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circlesView: UIStackView!
    @IBOutlet weak var doneButton: UIButton!

    // MARK: - User action handlers

    @IBAction func doneButton(_ sender: UIButton) {
        daysInput.resignFirstResponder()
        doneButton.isHidden = true
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

    @IBAction func resetButton(_ sender: UIButton) {
        reset()
        save()
    }

    @IBAction func startButton(_ sender: UIButton) {
        save()
        setModelState(.running)
        scheduleNotification(after: selectedInterval)
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        daysInput.delegate = self
        titleInput.delegate = self
        scrollView.delegate = self
        UNUserNotificationCenter.current().delegate = self

//        let now = Date()
//        startDatePicker.minimumDate = now - Utils.startDateBracket
//        startDatePicker.maximumDate = now + Utils.startDateBracket
//        print("Min: \(String(describing: startDatePicker.minimumDate!)), Max: \(String(describing: startDatePicker.maximumDate!))")

        createStartOptions()
        configureScrollView()
        configureCirclesView()

        reset()
        restore()
    }

    func createStartOptions() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, MMM d"
        let now = Date()
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents(in: TimeZone.current, from: now)
        let day = nowComponents.day!

        func replaceTitle(_ title: String, forOffset offset: Int) -> String {
            switch (offset) {
            case -1: return "Yesterday"
            case 0: return "Today"
            case 1: return "Tomorrow"
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

        print(startOptions)
    }

    private func configureScrollView() {

        let frameSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)

        for (index, element) in startOptions.enumerated() {
            let origin = CGPoint(x: frameSize.width * CGFloat(index), y: 0)
            let label = UILabel(frame: CGRect(origin: origin, size: frameSize))
            label.text = element.title
            label.font = UIFont.systemFont(ofSize: 36.0)
            label.textAlignment = .center
            
            scrollView.addSubview(label)
        }

        scrollView.contentSize = CGSize(width: frameSize.width * CGFloat(startOptions.count), height: frameSize.height)
        scrollView.isPagingEnabled = true
    }

    func configureCirclesView() {

        let radius: CGFloat = 5.0
        let size: CGFloat = 2.0 * radius
        let spacing = radius

        circlesView.axis = .horizontal
        circlesView.alignment = .center
        circlesView.distribution = .equalSpacing
        circlesView.spacing = spacing
        circlesView.backgroundColor = UIColor.lightGray
        circlesView.translatesAutoresizingMaskIntoConstraints = false

        for (_, _) in startOptions.enumerated() {
            let circle = UIView()
            circle.layer.borderWidth = 1.0
            circle.layer.borderColor = UIColor.darkGray.cgColor
            circle.layer.cornerRadius = radius
            let constraintW = circle.widthAnchor.constraint(equalToConstant: size)
            constraintW.isActive = true
            constraintW.priority = .defaultHigh
            let constraintH = circle.heightAnchor.constraint(equalToConstant: size)
            constraintH.isActive = true
            constraintH.priority = .defaultHigh

            circlesView.addArrangedSubview(circle)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CountdownViewController {
            prepareForPresenting(viewController)
        }
    }

    private func prepareForPresenting(_ viewController: CountdownViewController) {
        viewController.model = model
        viewController.dismissHandler = { () in
            self.reset()
            self.save()
        }
    }

    func setNumDays(_ numDays: Int) {

        daysInput.text = String(numDays)
        print("selected days: \(numDays)")

        selectedInterval = Double(numDays * Utils.secondsPerDay)
        //        picker.selectRow(row, inComponent: 0, animated: true) // TODO - loop?
    }

    func selectStartOption(_ index: Int, animated: Bool = false) {

        let option = startOptions[index]
        model.startDate = option.date
        updateTargetDate()
        updateProvisionalUI() // TODO - this kind of UI update should be in one place, probably layoutSubviews()

        let size = scrollView.contentSize
        let itemWidth = CGFloat(size.width) / CGFloat(startOptions.count)
        let offset = CGPoint(x: itemWidth * CGFloat(index), y: 0)
        scrollView.setContentOffset(offset, animated: true)

        for (i, view) in circlesView.subviews.enumerated() {
            view.backgroundColor = (i == index ? UIColor.darkGray : UIColor.white)
        }

        selectedStartOptionIndex = index
    }

    private func setModelState(_ state: TimerModel.State) {
        model.state = state
    }

    private func updateTargetDate() {
        let targetDate = Date(timeInterval: selectedInterval, since: model.startDate!)
        model.targetDate = targetDate
    }

    private func updateProvisionalUI() {

        let formatter = Utils.shared.dateOnlyFormatter // dateTimeFormatter
        let targetString = (model.startDate == nil ? "-" : formatter.string(from: model.targetDate!))

        provisionalDateLabel.text = targetString

        if (model.targetDate != nil) {
            let isPast = (model.targetDate! < Date())
//            startButton.isHidden = isPast
            provisionalDateLabel.textColor = (isPast ? UIColor.red : UIColor.darkText)
        }
    }

    private func reset() {
        print("RESET")

        // State, models
        setModelState(.notStarted)
        selectStartOption(-startOffsetPast) // Today
        setNumDays(1)

        model.targetDate = nil
        model.startDate = nil
        model.title = nil

        // UI
        titleInput.text = "" // TODO - do this in view update methods

//        startDatePicker.setDate(Date(), animated: true)
//        startDatePicker.isHidden = true

        updateProvisionalUI()

        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func save() {
        let defaults = UserDefaults.standard
        if (model.targetDate == nil) {
            print("Removing")
            defaults.removeObject(forKey: userDefaultsKey)
        }
        else {
            let tDate = model.targetDate!
            let cDate = model.startDate!
            print("Saving: \(Utils.shared.dateTimeFormatter.string(from: tDate)) >> \(Utils.shared.dateTimeFormatter.string(from: cDate))")

            let encoded = NSKeyedArchiver.archivedData(withRootObject: model)
            defaults.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func restore() {
        let defaults = UserDefaults.standard
        if let encoded = defaults.data(forKey: userDefaultsKey),
            let restoredModel = NSKeyedUnarchiver.unarchiveObject(with: encoded) as? TimerModel {
            model = restoredModel
            setModelState(.running) // TODO - computed property?
            print("Restored: \(model)")

            presentCountdownIfNeeded()
        }
        else {
            print("Nothing restored")
        }
    }

    private func presentCountdownIfNeeded() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countdownViewController")
        if let countdownViewController = viewController as? CountdownViewController {
            prepareForPresenting(countdownViewController)
            navigationController?.pushViewController(countdownViewController, animated: false)
        }
    }

    private func scheduleNotification(after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = model.title ?? "Timer expired"
        content.body = (model.targetDate == nil ? "" : Utils.shared.dateTimeFormatter.string(from: model.targetDate!))
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (interval + notificationDelay), repeats: false)

        let request = UNNotificationRequest(identifier: "notificationId",
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
    }
}

