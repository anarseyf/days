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
        if (textField == daysInput) {
            setDoneButtonHidden(false)
            setIncrementButtonsHidden(true)
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // titleInput only
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return daysInput.text != nil
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

            setDoneButtonHidden(!isDoneEnabled)
            setIncrementButtonsHidden(true)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let text: String = (daysInput.text ?? "").isEmpty ? "1" : daysInput.text!
        var numDays = Int(text) ?? 1
        numDays = min(max(numDays, Utils.minDays), Utils.maxDays)
        setNumDays(numDays)
        setIncrementButtonsHidden(false)
    }
}

// MARK: - CalendarDelegate

extension DaysSelectorViewController: CalendarDelegate {
    func didSelectDate(_ date: Date) {
        print("DAYS: didSelect \(date)")
        setStartDate(date)
    }

    func didShowMonth(startingOn startDate: Date) {
        print("DAYS: didShowMonth \(startDate)")
    }
}
