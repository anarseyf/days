//
//  ProgressViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let numBars = 5
    var barViews: [UIView] = []
    var cellData: [Int] = []

    var model: TimerModel? = nil {
        didSet {
            guard let totalDays = model?.totalDays else { return }

            print("total: \(totalDays)")

            let remainder = totalDays % numBars
            let numCells = totalDays / numBars + (remainder == 0 ? 0 : 1)
            cellData = Array(0..<numCells).enumerated().map { (index, _) in
                let windowStart = numBars * index
                let windowEnd = min(totalDays, numBars * (index + 1))
                return windowEnd - windowStart
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

        let numCompleted = cellData[indexPath.row]

        let bars = [cell.bar1, cell.bar2, cell.bar3, cell.bar4, cell.bar5]
        for (index, bar) in bars.enumerated() {
            let i = index + 1
            if (i < numCompleted) {
                bar?.backgroundColor = UIColor.darkGray
            }
            else if (i == numCompleted) {
                let isLast = (indexPath.row == cellData.count - 1)
                bar?.backgroundColor = (isLast ? UIColor.red : UIColor.darkGray)
            }
            else {
                bar?.backgroundColor = UIColor.lightGray
            }
        }

        return cell
    }
}
