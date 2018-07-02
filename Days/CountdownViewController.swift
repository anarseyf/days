//
//  CountdownViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {

    var model: TimerModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("COUNTDOWN: \(model?.description ?? "-")")
    }
}
