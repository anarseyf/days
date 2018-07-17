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

    let userDefaultsKey = "timerModel"
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

    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var daysInput: UITextField!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circlesView: UIStackView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var minusDayButton: UIButton!
    @IBOutlet weak var plusDayButton: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var startButton: UIButton!

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

    @IBAction func startButton(_ sender: UIButton) {

        if (model.state == .invalid) {
            print("Invalid model")
            return
        }

        model.isActive = true
        model.notificationDate = Utils.notificationDate(fromTarget: model.targetDate!)
        save()

        NotificationsHandler.reset()
        NotificationsHandler.schedule(on: model.notificationDate!, with: model)
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true

        daysInput.delegate = self
        titleInput.delegate = self
        scrollView.delegate = self
        UNUserNotificationCenter.current().delegate = self

        createStartOptions()
        configureScrollView()
        configureCirclesView()

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
    }

    private func configureScrollView() {

        let frameSize = CGSize(width: view.frame.size.width - 2 * arrowButtonWidth,
                               height: scrollView.frame.size.height)

        for (index, element) in startOptions.enumerated() {
            let origin = CGPoint(x: frameSize.width * CGFloat(index), y: 0)
            let label = UILabel(frame: CGRect(origin: origin, size: frameSize))
            label.text = element.title
            label.font = UIFont.systemFont(ofSize: 36.0)
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

    func configureCirclesView() {

        let radius: CGFloat = 4.0
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
            self.model.reset()
            self.save()
            self.resetUI()
        }
    }

    private func presentCountdownIfNeeded() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countdownViewController")
        if let countdownViewController = viewController as? CountdownViewController {
            prepareForPresenting(countdownViewController)
            navigationController?.pushViewController(countdownViewController, animated: false)
        }
    }

    func setNumDays(_ numDays: Int) {
        daysInput.text = String(numDays)
        daysLabel.text = Utils.daysString(from: numDays, withNumber: false)
        minusDayButton.isHidden = (numDays <= Utils.minDays)
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

        for (index, view) in circlesView.subviews.enumerated() {
            view.backgroundColor = (index == selectedStartOptionIndex ? UIColor.darkGray : UIColor.white)
        }

        leftArrow.isHidden = (selectedStartOptionIndex <= 0)
        rightArrow.isHidden = (selectedStartOptionIndex >= startOptions.count - 1)
    }

    private func resetUI() {
        setStartOptionToday()
        setNumDays(1)
        titleInput.text = "" // TODO - do this in view update methods / property observer or delegate on model?
        NotificationsHandler.reset()
    }

    private func save() {
        let defaults = UserDefaults.standard
        if (model.targetDate == nil) {
            print("Removing \(userDefaultsKey)")
            defaults.removeObject(forKey: userDefaultsKey)
        }
        else {
            print("Saving \(userDefaultsKey):\n\(model.description)")
            let encoded = NSKeyedArchiver.archivedData(withRootObject: model)
            defaults.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func restore() {
        let defaults = UserDefaults.standard
        if let encoded = defaults.data(forKey: userDefaultsKey),
            let restoredModel = NSKeyedUnarchiver.unarchiveObject(with: encoded) as? TimerModel {
            model = restoredModel
            print("Restored \(userDefaultsKey):\n\(model)")

            presentCountdownIfNeeded()
        }
        else {
            print("Nothing restored")
        }
    }

    private func setStartOptionToday() {
        selectStartOption(-startOffsetPast)
    }
}

