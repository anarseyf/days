//
//  CalendarViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

struct CalendarModel {
    let startDates: [Date]
    var selectedDate: Date?
}

class CalendarViewController: UIViewController, UIScrollViewDelegate, CalendarDelegate {

    var model: CalendarModel?
    var calendarDelegate: CalendarDelegate?

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsView: UIScrollView!
    
    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        Utils.blurifyView(self.view)

        monthsView.delegate = self

        guard let model = model else { return }

        let size = monthsView.frame.size
        monthsView.contentSize = CGSize(width: size.width,
                                        height: CGFloat(model.startDates.count) * size.height)
        monthsView.isPagingEnabled = true

        for (index, date) in model.startDates.enumerated() {
            let monthViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "monthViewController") as! MonthViewController

            let monthModel = Utils.calendarModel(forStartDate: date,
                                                 selectedDate: model.selectedDate)
            print(monthModel)

            monthViewController.model = monthModel
            monthViewController.delegate = self

            self.addChild(monthViewController)

            let origin = CGPoint(x: 0,
                                 y: CGFloat(index) * size.height)
            monthViewController.view.frame = CGRect(origin: origin, size: size)
            monthsView.addSubview(monthViewController.view)
        }

        updateLabel()
    }

    func updateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: model!.selectedDate!)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard var model = model else { return }

        let offsetFraction = Double(scrollView.contentOffset.y / scrollView.contentSize.height)
        let page = Int(Double(model.startDates.count) * offsetFraction)
        model.selectedDate = model.startDates[page]
        updateLabel()
    }

    // MARK: - CalendarDelegate

    func didSelectDate(_ date: Date?) {
        calendarDelegate?.didSelectDate(date)
        dismiss(animated: true, completion: nil)
    }
}
