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
            createSubviews()
            self.view.layoutIfNeeded()
        }
    }
    var calendarDelegate: CalendarDelegate?

    @IBOutlet weak var monthsView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        monthsView.delegate = self
    }

    func createSubviews() {
        guard let model = model else {
            print("Calendar VC: No model")
            return
        }

        let size = monthsView.frame.size
        monthsView.contentSize = CGSize(width: size.width,
                                        height: CGFloat(model.startDates.count) * size.height)
        monthsView.isPagingEnabled = true

        for (index, date) in model.startDates.enumerated() {
            let monthViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "monthViewController") as! MonthViewController

            let monthModel = CalendarMonthModel.build(forStartDate: date,
                                                      selectedDate: model.currentMonthStartDate)
            print(monthModel)

            monthViewController.model = monthModel
            monthViewController.delegate = self

            self.addChild(monthViewController)

            let origin = CGPoint(x: 0,
                                 y: CGFloat(index) * size.height)
            monthViewController.view.frame = CGRect(origin: origin, size: size)
            monthsView.addSubview(monthViewController.view)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CalendarViewController : UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard var model = model else { return }

        let offsetFraction = Double(scrollView.contentOffset.y / scrollView.contentSize.height)
        let page = Int(Double(model.startDates.count) * offsetFraction)
        model.currentMonthStartDate = model.startDates[page]

        calendarDelegate?.didShowMonth?(startingOn: model.currentMonthStartDate!)
    }
}

// MARK: - CalendarDelegate

extension CalendarViewController : CalendarDelegate {

    func didSelectDate(_ date: Date) {
        calendarDelegate?.didSelectDate?(date)
        dismiss(animated: true, completion: nil)
    }
}
