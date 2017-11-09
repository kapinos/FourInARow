//
//  ViewController.swift
//  FourInARow
//
//  Created by Anastasia on 11/8/17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit

struct Ball {
    var x   = -1.0
    var y   = -1.0
    var row = -1
    var col = -1
    
    init() { }
    
    init(x: Double, y: Double, row: Int, col: Int) {
        self.x = x
        self.y = y
        self.row = row
        self.col = col
    }
}

struct Sizes {
    static var BallSize     = -1
    static let Inset        = 10
    static let COLS         = 6
    static var ROWS         = -1
    static var NavBarHeight:CGFloat = -1.0
}

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
     var arrayBalls: [[Ball]] = []

    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapGestureRecognizer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        configureGeometryParameters()
        configureBalls()
       // printArray()
    }

    // MARK: - Inner Methods
    
    private func configureGeometryParameters() {
        Sizes.NavBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        // count balls size from the width
        Sizes.BallSize = Int(round((self.view.bounds.width - CGFloat(Sizes.Inset)) / CGFloat(Sizes.COLS) - CGFloat(Sizes.Inset)))
        
        // count amount of rows from the balls size
        let amountRows = (self.view.bounds.height - CGFloat(Sizes.Inset) - Sizes.NavBarHeight) / CGFloat(Sizes.BallSize + Sizes.Inset)
        Sizes.ROWS = Int(floor(amountRows))
        
        //print("ballSize = \(Sizes.BallSize), rows = \(Sizes.ROWS)\nwidth=\(self.view.bounds.width), height=\(self.view.bounds.height)")
        
        // init array of balls
        arrayBalls = Array(repeating: Array(repeating: Ball(), count: Sizes.COLS),
                           count: Sizes.ROWS)
    }
    
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        tapGestureRecognizer.delegate = self
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self.imageView)
        checkTouch(touchPoint)
    }
    
    func configureBalls()  {
        for row in 0..<Sizes.ROWS {
            var arr = [Ball]()
            for col in 0..<Sizes.COLS {
                arr.append(Ball(x: Double((Sizes.Inset + Sizes.BallSize) * col + Sizes.Inset),
                                y: Double((Sizes.Inset + Sizes.BallSize) * row + Sizes.Inset),
                                row: row, col: col))
            }
            arrayBalls[row] = arr
        }
    }
    
    func printArray() {
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                print("\(row) \(col), x:\(arrayBalls[row][col].x), y:\(arrayBalls[row][col].y)")
            }
        }
    }
    
    func checkTouch(_ touchPoint: CGPoint) {
        
        let touchX = touchPoint.x
        let touchY = touchPoint.y
        
        print("x: \(touchX), y: \(touchY)")
        
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                let minX = CGFloat(arrayBalls[row][col].x)
                let maxX = minX + CGFloat(Sizes.BallSize)
                
                let minY = CGFloat(arrayBalls[row][col].y)
                let maxY = minY + CGFloat(Sizes.BallSize)
                
                if (minX <= touchX && touchX <= maxX) && ( minY <= touchY && touchY <= maxY) {
                    let view = UIView(frame: CGRect(x: arrayBalls[row][col].x,
                                                    y: arrayBalls[row][col].y,
                                                    width: Double(Sizes.BallSize),
                                                    height: Double(Sizes.BallSize)))
                    view.backgroundColor = UIColor.darkGray
                    self.imageView.addSubview(view)
                }
            }
        }
    }

}

