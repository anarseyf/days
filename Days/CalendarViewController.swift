//
//  CalendarViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthLabel: UILabel!

    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let monthVC = children.first as? MonthViewController {
            var components = Calendar.current.dateComponents(in: .current, from: Date())
            components.day = 1
            components.hour = 0
            components.minute = 0
            components.second = 0
            monthVC.startDate = components.date

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            monthLabel.text = formatter.string(from: components.date!)
        }
    }
    
}
