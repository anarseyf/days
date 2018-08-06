//
//  ProgressViewController.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // TODO - enum with associated values?
    let excludedBarColor = UIColor.white.withAlphaComponent(0.0)
    let pastBarColor = UIColor(named: "pastBarColor")
    let presentBarColor = UIColor(named: "presentBarColor")
    let futureBarColor = UIColor(named: "futureBarColor")

    let barsPerCell = ProgressCell.barsPerCell
    let cellSize: CGFloat = 36.0
    let cellSpacing: CGFloat = 10.0
    let minTotalSpacing: CGFloat = 40.0
    var barViews: [UIView] = []
    var cellData: [ProgressCell.Datum] = []

    var model: TimerModel? = nil {
        didSet {
            guard let model = model else { return }
            if model.state == .invalid { return }

            var unaccountedTotal = model.totalDays!
            let currentDay = ( model.state == .willRun ? 0
                           : ( model.state == .running ? model.currentDay!
                           : model.totalDays! + 1 ))
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
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds

        let viewWidth = collectionView.frame.width

        var cellsPerRow = Int((viewWidth - minTotalSpacing) / cellSize)
        cellsPerRow = min(cellsPerRow, cellData.count)
        let totalSpacing = CGFloat(cellsPerRow - 1) * cellSpacing
        let totalCellsWidth = cellSize * CGFloat(cellsPerRow)
        let inset = (viewWidth - totalSpacing - totalCellsWidth)/2

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.collectionViewLayout = layout
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "progressCell", for: indexPath) as! ProgressCell

        let datum = cellData[indexPath.row]
        cell.datum = datum

        // TODO - move this logic to ProgressCell:layoutSubviews()?
        // TODO - named colors (asset catalog)

        let bars = [cell.bar1, cell.bar2, cell.bar3, cell.bar4, cell.bar5]
        for (index, bar) in bars.enumerated() {

            let i = index + 1
            if (i > datum.totalDays) { // invisible
                bar?.backgroundColor = excludedBarColor
            }
            else if (i == datum.currentDayRelative) { // current day
                bar?.backgroundColor = futureBarColor
                UIView.animate(withDuration: 1.3,
                               delay: 0.0,
                               options: [.repeat, .autoreverse],
                               animations: {
                                    bar?.backgroundColor = self.presentBarColor },
                               completion: nil)
            }
            else if (i > datum.currentDayRelative) { // future day
                bar?.backgroundColor = futureBarColor
            }
            else { // past day
                bar?.backgroundColor = pastBarColor
            }
        }

        return cell
    }


}
