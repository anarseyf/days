//
//  DaysSelectorViewController+Extensions.swift
//  Days
//
//  Created by Anar Seyf on 7/9/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

extension DaysSelectorViewController : UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }

}

extension DaysSelectorViewController : UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = days[row]
        return String(value) + (value == 1 ? " day" : " days")
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectDaysIndex(row)
    }

}

extension DaysSelectorViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge])
    }

}

extension DaysSelectorViewController : UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // TODO - disable Start and re-enable in didEndEditing
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        model.title = textField.text
    }
}

extension DaysSelectorViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(Double(startDateOptions.count) * Double(scrollView.contentOffset.x / scrollView.contentSize.width))
        print("page: \(page)")

        for (index, view) in circlesView.subviews.enumerated() {
            view.backgroundColor = (index == page ? UIColor.darkGray : UIColor.white)
        }
    }
}
