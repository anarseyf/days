//
//  BubbleViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/5/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class BubbleViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    var circleView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.frame = view.bounds

        if (circleView == nil) {
            addCircleView()
        }
    }

    private func addCircleView() {

        print("Circle \(view.frame) \(view.bounds)")

        let margin: CGFloat = 1.0
        let width = view.frame.width,
            height = view.frame.height,
            diameter = min(width, height) - 2 * margin
        let origin = CGPoint(x: margin, y: margin)
        let size = CGSize(width: diameter, height: diameter)
        let frame = CGRect(origin: origin, size: size)
        let circleView = UIView(frame: frame)

        let color = UIColor(named: "linkColor")!
        circleView.layer.borderColor = color.cgColor
        circleView.layer.borderWidth = 3.0
        circleView.layer.cornerRadius = diameter/2

        circleView.backgroundColor = .white
        circleView.clipsToBounds = true

        let imageWidth = diameter / 2 // sqrt(2)
        let imageOffset = (diameter - imageWidth)/2
        let imageFrame = CGRect(x: imageOffset,
                                y: imageOffset,
                                width: imageWidth,
                                height: imageWidth)
        let imageView = UIImageView(frame: imageFrame)
        imageView.image = UIImage(named: "owl")
        circleView.addSubview(imageView)

        contentView.addSubview(circleView)

        self.circleView = circleView
    }
}
