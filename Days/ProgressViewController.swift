//
//  ProgressViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    struct ProgressCellData : CustomStringConvertible {
        let numTotal: Int
        let numElapsed: Int

        var description: String {
            return "\(numTotal)/\(numElapsed)"
        }
    }

    let barsPerCell = 5
    var barViews: [UIView] = []
    var cellData: [ProgressCellData] = []

    var model: TimerModel? = nil {
        didSet {
            guard var unaccountedTotal = model?.totalDays else { return }
            var unaccountedElapsed = model!.elapsedDays!

            print("total: \(unaccountedTotal), elapsed: \(unaccountedElapsed)")

            while (unaccountedTotal > 0) {

                let numTotal = min(barsPerCell, unaccountedTotal)
                let numElapsed = min(barsPerCell, unaccountedElapsed)

                let datum = ProgressCellData(numTotal: numTotal, numElapsed: numElapsed)
                cellData.append(datum)

                unaccountedTotal -= datum.numTotal
                unaccountedElapsed -= datum.numElapsed
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

        // TODO - move this logic to ProgressCell:

        let bars = [cell.bar1, cell.bar2, cell.bar3, cell.bar4, cell.bar5]
        for (index, bar) in bars.enumerated() {
            let i = index + 1
            if (i > datum.numTotal) { // invisible
                bar?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            }
            else if (i > datum.numElapsed) { // future day
                bar?.backgroundColor = UIColor.lightGray
            }
            else if (i == datum.numElapsed) { // current day
                bar?.backgroundColor = UIColor.red
            }
            else { // past day
                bar?.backgroundColor = UIColor.darkGray
            }
        }

        return cell
    }
}
