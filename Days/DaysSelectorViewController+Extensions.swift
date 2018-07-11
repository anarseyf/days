//
//  DaysSelectorViewController+Extensions.swift
//  Days
//
//  Created by Anar Seyf on 7/9/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit
import UserNotifications

// MARK: - UNUserNotificationCenterDelegate

extension DaysSelectorViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge])
    }

}

// MARK: - UITextFieldDelegate

extension DaysSelectorViewController : UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // TODO - disable Start and re-enable in didEndEditing
        if (textField == daysInput) {
            doneButton.isHidden = false
            minusDayButton.isHidden = true
            plusDayButton.isHidden = true
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // titleInput only
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField == titleInput) {
            return true
        }
        else {
            return daysInput.text != nil
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == daysInput) {
            var isDoneEnabled = false
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                isDoneEnabled = (updatedText.count > 0)
            }

            doneButton.isHidden = !isDoneEnabled
            minusDayButton.isHidden = true
            plusDayButton.isHidden = true
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == titleInput) {
            model.title = textField.text
        }
        else if (textField == daysInput) {

            let text: String = (daysInput.text ?? "").isEmpty ? "1" : daysInput.text!
            var numDays = Int(text) ?? 1

            numDays = min(max(numDays, Utils.minDays), Utils.maxDays)

            setNumDays(numDays)

            minusDayButton.isHidden = false
            plusDayButton.isHidden = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DaysSelectorViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(Double(startOptions.count) * Double(scrollView.contentOffset.x / scrollView.contentSize.width))
        
        selectStartOption(page, animated: true)
    }
}
