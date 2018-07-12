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
    var cellData: [Int] = []

    var model: TimerModel? = nil {
        didSet {
            guard let totalDays = model?.totalDays else { return }

            label.text = "total days: \(totalDays)"

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

    @IBOutlet weak var label: UILabel!
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
        cell.completed = cellData[indexPath.row]
        return cell
    }
}
