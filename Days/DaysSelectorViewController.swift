//
//  ViewController.swift
//  Days
//
//  Created by Anar Seyf on 6/28/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class DaysSelectorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let secondsPerDay = 60 * 60 * 24
    var days = Array(0...100)
    var selectedDate = Date()
    var dateFormatter = DateFormatter()
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    func titleForRow(_ row: Int) -> String {
        return String(days[row])
    }

    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let seconds = Double(row * secondsPerDay)
        selectedDate = Date(timeIntervalSinceNow: seconds)
        
        dateLabel.isHidden = false
        dateLabel.text = dateFormatter.string(from: selectedDate)
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        countdownLabel.isHidden = false
        countdownLabel.text = "Started"
    }
}

