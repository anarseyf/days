//
//  MonthViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

@objc protocol CalendarDelegate {
    @objc optional func didSelectDate(_ date: Date?)
    @objc optional func didShowMonth(startingOn startDate: Date)
}

class CalendarTapGestureRecognizer : UITapGestureRecognizer {
    var dayModel: CalendarDayModel?
    init(_ dayModel: CalendarDayModel?, target: Any?, action: Selector?) {
        self.dayModel = dayModel
        super.init(target: target, action: action)
    }
}

class MonthViewController: UIViewController {

    var model: CalendarMonthModel?
    var delegate: CalendarDelegate?
    var didLayoutSubviews = false
    let labelHeight: CGFloat = 30.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            if let monthModel = model {

                let cellWidth = floor(view.frame.width / CGFloat(monthModel.matrix.first!.count))
                let cellHeight = floor(view.frame.height / CGFloat(monthModel.matrix.count + 1)) // TODO - always 6 rows

                let formatter = DateFormatter()
                formatter.dateFormat = "E"
                let weekdaysRow = monthModel.matrix[1].map { model in
                    return formatter.string(from: model!.date)
                }

                for (rowIndex, weekday) in weekdaysRow.enumerated() {
                    let origin = CGPoint(x: CGFloat(rowIndex) * cellWidth, y: 0.0)
                    let size = CGSize(width: cellWidth, height: cellHeight)
                    let headerView = CalendarHeaderView(weekday: weekday,
                                                        frame: CGRect(origin: origin, size: size))
                    view.addSubview(headerView)
                }

                for (rowIndex, row) in monthModel.matrix.enumerated() {
                    let originY = CGFloat(rowIndex + 1) * cellHeight
                    for (colIndex, dayModel) in row.enumerated() {
                        let originX = CGFloat(colIndex) * cellWidth
                        let origin = CGPoint(x: originX, y: originY)
                        let size = CGSize(width: cellWidth, height: cellHeight)
                        let dayView = CalendarDayView(model: dayModel,
                                                      frame: CGRect(origin: origin, size: size))

                        let tapRecognizer = CalendarTapGestureRecognizer(dayModel, target: self, action: #selector(didSelectDate(_:)))
                        tapRecognizer.cancelsTouchesInView = false
                        dayView.addGestureRecognizer(tapRecognizer)

                        view.addSubview(dayView)
                    }
                }

                didLayoutSubviews = true
            }
        }
    }

    @objc func didSelectDate(_ sender: CalendarTapGestureRecognizer) {
        delegate?.didSelectDate?(sender.dayModel?.date)
    }
}
