//
//  ViewController.swift
//  FourInARow
//
//  Created by Anastasia on 11/8/17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit

struct Position {
    var row = 0
    var col = 0
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

struct Ball {
    var point: CGPoint = CGPoint(x: -1, y: -1)
    var position = Position(row: -1, col: -1)
    var size = Sizes.BallSize
    
    init() { }
    
    init(point: CGPoint, position: Position) {
        self.point = point
        self.position = position
    }
}

enum Player: String {
    case first  = "first"
    case second = "second"
    case none   = "none"
}

struct BallView {
    var ball = Ball()
    var player = Player.none
    
    init() { }
    
    init(ball: Ball) {
        self.ball = ball
    }
}

struct Sizes {
    static var BallSize: CGFloat    = -1
    static let Inset: CGFloat       = 5
    static let COLS         = 6
    static var ROWS         = -1
}

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    var arrayBalls: [[Ball]] = []
    var arrayBallViews: [[BallView]] = []

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
    }

    // MARK: - Inner Methods
    
    private func configureGeometryParameters() {
        
        // calculate balls size from the width
        Sizes.BallSize = ((self.imageView.bounds.width - Sizes.Inset) / CGFloat(Sizes.COLS)) - Sizes.Inset
        
        // calculate amount of rows from the balls size
        let amountRows = (self.imageView.bounds.height - Sizes.Inset) / (Sizes.BallSize + Sizes.Inset)
        print("amountRows \(amountRows)")
        Sizes.ROWS = Int(floor(amountRows))
        
        print("ballSize = \(Sizes.BallSize), rows = \(Sizes.ROWS)\nwidth=\(self.imageView.bounds.width), height=\(self.imageView.bounds.height)")
        
        // init array of balls !!!!!! simple
        arrayBalls = Array(repeating: Array(repeating: Ball(), count: Sizes.COLS),
                           count: Sizes.ROWS)
        arrayBallViews = Array(repeating: Array(repeating: BallView(), count: Sizes.COLS),
                               count: Sizes.ROWS)
        configureBalls()
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
            var arrBalls = [Ball]()
            var arrBallViews = [BallView]()
            for col in 0..<Sizes.COLS {
                let ball = Ball(point: CGPoint(x: (Sizes.Inset + Sizes.BallSize) * CGFloat(col) + Sizes.Inset,
                                               y: (Sizes.Inset + Sizes.BallSize) * CGFloat(row) + Sizes.Inset),
                                position: Position(row: row, col: col))
                arrBalls.append(ball)
                arrBallViews.append(BallView(ball: ball))
            }
            arrayBalls[row] = arrBalls
            arrayBallViews[row] = arrBallViews
        }
    }
    
    
    func checkTouch(_ touchPoint: CGPoint) {
        
        print("x: \(touchPoint.x), y: \(touchPoint.y)")
        
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                
                let rect = CGRect(origin: touchPoint, size: CGSize(width: Sizes.BallSize, height: Sizes.BallSize))

                // find the position of ball for tap
                if !rect.contains(touchPoint) {
                    continue
                } else {
                    let rowForSet = getLastFreeRow(tappedRow: row, tappedCol: col)
            
                    arrayBallViews[rowForSet][col].player = Player.first
                    
                    let ball = arrayBallViews[rowForSet][col].ball
                    let view = UIView(frame: CGRect(origin: ball.point,
                                                    size: CGSize(width: ball.size, height: ball.size)))
                    
                    view.backgroundColor = UIColor.blue
                    self.imageView.addSubview(view)
                }
            }
        }
    }

   private func getLastFreeRow(tappedRow: Int, tappedCol: Int) -> Int {
        var rowForBall = tappedRow
        
        for r in tappedRow..<Sizes.ROWS {
            if arrayBallViews[r][tappedCol].player == .none {
                rowForBall = r
            } else {
                break
            }
        }
        return rowForBall
    }
}

