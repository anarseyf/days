//
//  CalendarViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UIScrollViewDelegate {

    var startDates: [Date]?
    var selectedDate: Date?

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsView: UIScrollView!
    
    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        monthsView.delegate = self

        var components = Calendar.current.dateComponents(in: .current, from: Date())
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0

        let startDates = [0,1,2,3].map { index -> Date in
            var currentComponents = components
            currentComponents.month = components.month! + index
            return currentComponents.date!
        }

        let size = monthsView.frame.size
        monthsView.contentSize = CGSize(width: size.width,
                                        height: CGFloat(startDates.count) * size.height)
        monthsView.isPagingEnabled = true

        for (index, date) in startDates.enumerated() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "monthViewController")
            if let monthViewController = vc as? MonthViewController {
                monthViewController.startDate = date
                self.addChild(monthViewController)

                let origin = CGPoint(x: 0,
                                     y: CGFloat(index) * size.height)
                monthViewController.view.frame = CGRect(origin: origin, size: size)
                monthsView.addSubview(monthViewController.view)
            }
        }

        self.startDates = startDates
        self.selectedDate = startDates[0]
        updateLabel()
    }

    func updateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: selectedDate!)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(Double(startDates!.count) * Double(scrollView.contentOffset.y / scrollView.contentSize.height))

        selectedDate = startDates![page]
        updateLabel()
    }
}
