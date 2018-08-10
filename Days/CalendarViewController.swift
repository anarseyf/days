//
//  CalendarViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

@objc protocol CalendarDelegate {
    @objc optional func didSelectDate(_ date: Date)
    @objc optional func didShowMonth(startingOn startDate: Date)
}

class CalendarViewController: UIViewController {

    var model: CalendarModel? {
        didSet {
            updateMonths()
            view.setNeedsLayout()
        }
    }
    var didConfigureViews = false
    var calendarDelegate: CalendarDelegate?

    @IBOutlet weak var monthsView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        monthsView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let model = model else { return }

        if !didConfigureViews {
            configureMonthsView()
            createMonths()
            didConfigureViews = true
        }
        updateMonths()
    }

    func configureMonthsView() {
        guard let model = model else {
            print("Calendar VC: No model")
            return
        }

        let size = monthsView.frame.size
        monthsView.contentSize = CGSize(width: size.width,
                                        height: CGFloat(model.monthStartDates.count) * size.height)
        monthsView.isPagingEnabled = true
    }

    func createMonths() {
        guard let model = model else { return }

        let size = monthsView.frame.size

        for index in 0 ..< model.monthStartDates.count {
            let monthViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "monthViewController") as! MonthViewController

            monthViewController.delegate = self

            self.addChild(monthViewController)

            let origin = CGPoint(x: 0,
                                 y: CGFloat(index) * size.height)
            monthViewController.view.frame = CGRect(origin: origin, size: size)
            monthsView.addSubview(monthViewController.view)
        }
    }

    func updateMonths() {
        guard let model = model else { return }
        if self.children.isEmpty { return }

        for (index, date) in model.monthStartDates.enumerated() {

            let monthViewController = self.children[index] as! MonthViewController
            let monthModel = CalendarMonthModel.build(forStartDate: date,
                                                      selectedDate: model.selectedDate)
            print(monthModel)
            monthViewController.model = monthModel
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CalendarViewController : UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard var model = model else { return }

        let offsetFraction = Double(scrollView.contentOffset.y / scrollView.contentSize.height)
        let page = Int(Double(model.monthStartDates.count) * offsetFraction)
        model.currentMonthStartDate = model.monthStartDates[page]

        calendarDelegate?.didShowMonth?(startingOn: model.currentMonthStartDate!)
    }
}

// MARK: - CalendarDelegate

extension CalendarViewController : CalendarDelegate {

    func didSelectDate(_ date: Date) {
        calendarDelegate?.didSelectDate?(date)
        model?.selectedDate = date
        updateMonths()
    }
}
