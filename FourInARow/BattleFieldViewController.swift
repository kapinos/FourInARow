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


struct Sizes {
    static var BallSize: CGFloat    = -1
    static let Inset: CGFloat       = 1
    static let COLS                 = 6
    static var ROWS                 = -1
}

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    var arrayBallViews: [[BallView]] = []
    var fieldImageView = UIView()

    // MARK: - IBOutlets
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(fieldImageView)
        
        configureTapGestureRecognizer()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureGeometryParameters()
    }

    // MARK: - Inner Methods
    
    private func configureGeometryParameters() {
        
        // calculate balls size from the width
        Sizes.BallSize = ((self.view.bounds.width - Sizes.Inset) / CGFloat(Sizes.COLS)) - Sizes.Inset
        
        // calculate amount of rows from the balls size
        let navBarHeight: CGFloat = self.navigationController?.navigationBar.frame.size.height ?? 0
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let availableHeight = self.view.bounds.height - navBarHeight - statusBarHeight
        
        let amountRows = (availableHeight - Sizes.Inset) / (Sizes.BallSize + Sizes.Inset)
        print("amountRows: \(amountRows)")
        Sizes.ROWS = Int(floor(amountRows))
        
        let size = CGSize(width: self.view.bounds.width,
                          height: CGFloat(Sizes.ROWS) * (Sizes.BallSize + Sizes.Inset) + Sizes.Inset)
        
        //print("self.view.height: \(self.view.bounds.height)\nnavBar: \(navBarHeight)\nstatusBar: \(statusBarHeight)\navailableHeight: \(availableHeight)\nsize.height: \(size.height)\nshift: \(shift)") // LOG
        
        fieldImageView.frame = CGRect(x: 0,
                                      y: statusBarHeight + navBarHeight + (availableHeight - size.height) / 2,
                                      width: size.width,
                                      height: size.height)
        
        self.fieldImageView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0)
        print("ballSize = \(Sizes.BallSize), rows = \(Sizes.ROWS)\nwidth=\(self.fieldImageView.bounds.width), height=\(self.fieldImageView.bounds.height)") // LOG
        configureBalls()
    }
    
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        tapGestureRecognizer.delegate = self
        self.fieldImageView.isUserInteractionEnabled = true
        self.fieldImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self.fieldImageView)
        checkTouch(touchPoint)
    }
    
    func configureBalls()  {
        for row in 0..<Sizes.ROWS {
            var arrBallViews = [BallView]()
            for col in 0..<Sizes.COLS {
                let ball = Ball(point: CGPoint(x: (Sizes.Inset + Sizes.BallSize) * CGFloat(col) + Sizes.Inset,
                                               y: (Sizes.Inset + Sizes.BallSize) * CGFloat(row) + Sizes.Inset),
                                position: Position(row: row, col: col))
                
                let ballView = BallView(currentBall: ball)
                ballView.frame = CGRect(origin: ball.point,
                                        size: CGSize(width: ball.size, height: ball.size))
                arrBallViews.append(ballView)
            }
            arrayBallViews.append(arrBallViews)
        }
    }
        
    func checkTouch(_ touchPoint: CGPoint) {
        
        //print("x: \(touchPoint.x), y: \(touchPoint.y)") // LOG
        
        let col = Int(touchPoint.x / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        let row = Int(touchPoint.y / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        
        //print("col: \(col), row: \(row)") // LOG

        let rowForSet = getLastFreeRow(tappedRow: row, tappedCol: col)
        // FIXME: check
        let ballView = arrayBallViews[rowForSet][col]
        ballView.image =  UIImage(named: Player.first.rawValue)
        ballView.changePlayer(player: .first)
        self.fieldImageView.addSubview(ballView)
    }

   private func getLastFreeRow(tappedRow: Int, tappedCol: Int) -> Int {
        var rowForBall = tappedRow
        
        for r in tappedRow ..< Sizes.ROWS {
            if arrayBallViews[r][tappedCol].player == .none {
                rowForBall = r
            } else {
                break
            }
        }
        return rowForBall
    }
}

