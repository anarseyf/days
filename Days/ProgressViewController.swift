//
//  ProgressViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let barsPerCell = ProgressCell.barsPerCell
    var barViews: [UIView] = []
    var cellData: [ProgressCell.Datum] = []

    var model: TimerModel? = nil {
        didSet {
            guard let model = model else { return }
            if model.state == .invalid { return }

            var unaccountedTotal = model.totalDays!
            var completedDays = model.completedDays!
            var currentDay = completedDays + 1
            var currentDayRelative = currentDay

            print("total: \(unaccountedTotal), current(absolute): \(currentDay)")

            while (unaccountedTotal > 0) {

                let numTotal = min(barsPerCell, unaccountedTotal)
                let datum = ProgressCell.Datum(totalDays: numTotal, currentDayRelative: currentDayRelative)
                cellData.append(datum)

                unaccountedTotal -= datum.totalDays
                currentDayRelative -= barsPerCell
            }

            print(cellData)

            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.darkGray.cgColor

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "progressCell", for: indexPath) as! ProgressCell

        let datum = cellData[indexPath.row]

        // TODO - move this logic to ProgressCell:layoutSubviews()?
        // TODO - named colors (asset catalog)

        let bars = [cell.bar1, cell.bar2, cell.bar3, cell.bar4, cell.bar5]
        for (index, bar) in bars.enumerated() {
            let i = index + 1
            if (i > datum.totalDays) { // invisible
                let transparentColor = UIColor.white.withAlphaComponent(0.0)
                bar?.backgroundColor = transparentColor
                bar?.layer.borderColor = UIColor.green.cgColor
            }
            else if (i == datum.currentDayRelative) { // current day
                bar?.backgroundColor = UIColor.red
            }
            else if (i > datum.currentDayRelative) { // future day
                bar?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
            }
            else { // past day
                bar?.backgroundColor = UIColor.darkGray
            }
        }

        return cell
    }
}
