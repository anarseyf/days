//
//  ProgressCell.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressCell: UICollectionViewCell {

    struct Datum : CustomStringConvertible {
        let numTotal: Int
        let numElapsed: Int

        var description: String {
            return "\(numTotal)/\(numElapsed)"
        }
    }

    @IBOutlet weak var bar1: ProgressCellBar!
    @IBOutlet weak var bar2: ProgressCellBar!
    @IBOutlet weak var bar3: ProgressCellBar!
    @IBOutlet weak var bar4: ProgressCellBar!
    @IBOutlet weak var bar5: ProgressCellBar!

    static let barsPerCell = 5
    
    var datum: ProgressCell.Datum?

    private let barWidth: CGFloat = 8.0
    private let horizontalMargin: CGFloat = 10.0

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if (newSuperview == nil) { return }
        
//        print("view: \(self.frame)")
//        print("superview: \(newSuperview!.frame)")

        self.clipsToBounds = false // TODO - remove
        self.layer.borderColor = UIColor.lightGray.cgColor

        let bars = [bar1, bar2, bar3, bar4, bar5]
        let verticalBarOrigin = CGPoint(x: 0, y: 0)
        let availableHorizontalSpace = self.frame.width - 2 * horizontalMargin

        let verticalBarHorizontalSpace = availableHorizontalSpace/4

        let barSize = CGSize(width: barWidth, height: self.frame.height)

        for (index, optionalBar) in bars.enumerated() {

            guard let bar = optionalBar else { return }

            let layer = bar.layer
            layer.cornerRadius = barWidth/2
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.white.cgColor

            bar.frame.size = barSize

            if (index < bars.count - 1) { // vertical
                bar.frame.origin = verticalBarOrigin
                bar.frame.origin.x = horizontalMargin
                    + (CGFloat(index) * verticalBarHorizontalSpace)
                    + verticalBarHorizontalSpace/2
                    - barWidth/2
            }
            else { // diagonal
                bar.frame.size.height = bar.frame.height * 1.2
                bar.center = CGPoint(x: self.bounds.width/2,
                                     y: self.bounds.height/2)
                bar.transform = CGAffineTransform(rotationAngle: .pi * 0.7)

                bar.removeFromSuperview()
                self.addSubview(bar)
            }
        }
    }
}
