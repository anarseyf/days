//
//  MonthViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class MonthViewController: UIViewController {

    private class CalendarTapGestureRecognizer : UITapGestureRecognizer {
        var dayModel: CalendarDayModel?
        init(_ dayModel: CalendarDayModel?, target: Any?, action: Selector?) {
            self.dayModel = dayModel
            super.init(target: target, action: action)
        }
    }

    var model: CalendarMonthModel?
    var delegate: CalendarDelegate?
    var didLayoutSubviews = false

    let labelHeight: CGFloat = 30.0
    let calendarRows = 6

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            if let monthModel = model {

                let label = UILabel(frame: CGRect(origin: .zero,
                                                  size: CGSize(width: view.frame.width,
                                                               height: labelHeight)))
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                label.text = formatter.string(from: monthModel.startDate)
                label.textColor = UIColor(named: "secondaryTextColor")
                label.textAlignment = .right
                label.font = UIFont.boldSystemFont(ofSize: 21.0)
                view.addSubview(label)

                formatter.dateFormat = "E"
                let weekdaysRow: [String] = monthModel.matrix[1].map { dayModel in
                    let str = formatter.string(from: dayModel!.date)
                    return String(str[...str.startIndex])
                }

                var offsetY = labelHeight
                let availableHeight = view.frame.height - offsetY

                let cellWidth = floor(view.frame.width / CGFloat(monthModel.matrix.first!.count))
                let cellHeight = floor(availableHeight / CGFloat(calendarRows + 1))

                for (rowIndex, weekday) in weekdaysRow.enumerated() {
                    let origin = CGPoint(x: CGFloat(rowIndex) * cellWidth, y: offsetY)
                    let size = CGSize(width: cellWidth, height: cellHeight)
                    let headerView = CalendarHeaderView(weekday: weekday,
                                                        frame: CGRect(origin: origin, size: size))
                    view.addSubview(headerView)
                }

                offsetY += cellHeight

                for (rowIndex, row) in monthModel.matrix.enumerated() {
                    let originY = offsetY + CGFloat(rowIndex) * cellHeight
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

    @objc private func didSelectDate(_ sender: CalendarTapGestureRecognizer) {
        if let dayModel = sender.dayModel {
            delegate?.didSelectDate?(dayModel.date)
        }
    }
}
