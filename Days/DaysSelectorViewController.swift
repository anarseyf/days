//
//  ViewController.swift
//  Days
//
//  Created by Anar Seyf on 6/28/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

class DaysSelectorViewController: UIViewController {

    // MARK: - Properties

    let notificationDelay = 3.0
    let userDefaultsKey = "timerModel"
    let days = Array(1...365)
    let startDateOptions = ["Yesterday", "Today", "Tomorrow"]
    var model = TimerModel()

    var selectedInterval: TimeInterval = 0.0 {
        didSet {
            let createdDate = model.createdDate ?? Date()
            model.createdDate = createdDate
            updateTargetDate()
            updateProvisionalUI()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var provisionalDateLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circlesView: UIStackView!

    // MARK: - User action handlers

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
        
        picker.delegate = self
        picker.dataSource = self
        titleInput.delegate = self
        scrollView.delegate = self
        UNUserNotificationCenter.current().delegate = self

//        let now = Date()
//        startDatePicker.minimumDate = now - Utils.startDateBracket
//        startDatePicker.maximumDate = now + Utils.startDateBracket
//        print("Min: \(String(describing: startDatePicker.minimumDate!)), Max: \(String(describing: startDatePicker.maximumDate!))")

        configureScrollView()
        configureCirclesView()
        reset()
        restore()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CountdownViewController {
            prepareForPresenting(viewController)
        }
    }

    private func configureScrollView() {

        let frameSize = CGSize(width: view.frame.size.width, height: scrollView.frame.size.height)

        for (index, element) in startDateOptions.enumerated() {
            let origin = CGPoint(x: frameSize.width * CGFloat(index), y: 0)
            let label = UILabel(frame: CGRect(origin: origin, size: frameSize))
            label.text = element
            label.font = UIFont.systemFont(ofSize: 36.0)
            label.textAlignment = .center
            
            scrollView.addSubview(label)
        }

        scrollView.contentSize = CGSize(width: frameSize.width * CGFloat(startDateOptions.count), height: frameSize.height)
        scrollView.isPagingEnabled = true
    }

    func configureCirclesView() {

        let radius: CGFloat = 8.0
        let size: CGFloat = 2.0 * radius
        let spacing = radius

        circlesView.axis = .horizontal
        circlesView.alignment = .center
        circlesView.distribution = .equalSpacing
        circlesView.spacing = spacing
        circlesView.backgroundColor = UIColor.lightGray
        circlesView.translatesAutoresizingMaskIntoConstraints = false

        for (_, _) in startDateOptions.enumerated() {
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

    private func prepareForPresenting(_ viewController: CountdownViewController) {
        viewController.model = model
        viewController.dismissHandler = { () in
            self.reset()
            self.save()
        }
    }

    func selectDaysIndex(_ row: Int) {
        let numDays = days[row]
        selectedInterval = Double(numDays * Utils.secondsPerDay)
//        picker.selectRow(row, inComponent: 0, animated: true) // TODO - loop?
    }

    private func setModelState(_ state: TimerModel.State) {
        model.state = state
    }

    private func updateTargetDate() {
        let targetDate = Date(timeInterval: selectedInterval, since: model.createdDate!)
        model.targetDate = targetDate
    }

    private func updateProvisionalUI() {

        let formatter = Utils.shared.dateOnlyFormatter // dateTimeFormatter
        let targetString = (model.createdDate == nil ? "-" : formatter.string(from: model.targetDate!))

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
        selectDaysIndex(0)

        model.targetDate = nil
        model.createdDate = nil
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
            let cDate = model.createdDate!
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

