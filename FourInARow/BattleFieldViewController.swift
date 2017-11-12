//
//  BattleFieldViewController.swift
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
    static let AmountBallsForWin    = 4
}

enum Directions {
    case Vertical, Horizontal, DiagonalToRight, DiagonalToLeft
}

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    private var arrayBallViews: [[BallView]] = []
    private var fieldView = UIView()
    private var isFirstPlayerTurn = true
    private var countTurn: Int = 0 {
        willSet {
            self.countTurnes.title = newValue == 0 ? "" : "\(newValue)"
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var countTurnes: UIBarButtonItem!
    
    // MARk: - User Actions
    @IBAction func newGameTapped(_ sender: UIBarButtonItem) {
        createAlert(isSomeoneWin: false)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(fieldView)
        
        // show the turn in title NavBar
        self.title = (isFirstPlayerTurn ? "Red" : "Blue") + " player"
        
        configureTapGestureRecognizer()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureGeometryParameters()
    }
    
    //================================================================================================
    // Detect winner Logic
    func checkByDirection(row: Int, col: Int, direction: Directions) {
        var arraySumm = 0
        let currentPlayer: Player = isFirstPlayerTurn ? Player.first : Player.second

        for i in -Sizes.AmountBallsForWin..<Sizes.AmountBallsForWin {
            
            var r = -1
            var c = -1
            
            switch direction {
            case .Vertical:
                r = row + i
                c = col
            case .Horizontal:
                r = row
                c = col + i
            case .DiagonalToRight:
                r = row + i
                c = col + i
            case .DiagonalToLeft:
                r = row + i
                c = col - i
            }
            
            if !isValidCoordinates(row: r, col: c) {
                continue
            }
            if arrayBallViews[r][c].player != currentPlayer {
                arraySumm = 0
            } else {
                arraySumm += 1
                print("row:\(r) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm) \(direction)")
                if isPlayerWin(currentSumm: arraySumm) { return }
            }
        }
    }
    
    private func checkForWin(_ countTurn: Int, row: Int, col: Int) {
        print("turn: \(countTurn)")
        // →
        checkByDirection(row: row, col: col, direction: .Horizontal)
        // ↓
        checkByDirection(row: row, col: col, direction: .Vertical)
        // ↘
        checkByDirection(row: row, col: col, direction: .DiagonalToRight)
        // ↙
        checkByDirection(row: row, col: col, direction: .DiagonalToLeft)
    }

    
    private func isValidCoordinates(row: Int, col: Int) -> Bool {
        if row < 0 || row >= Sizes.ROWS { return false }
        if col < 0 || col >= Sizes.COLS { return false }
        return true
    }
    
    private func isPlayerWin(currentSumm: Int) -> Bool {
        if currentSumm == Sizes.AmountBallsForWin {
            createAlert(isSomeoneWin: true)
            return true
        }
        return false
    }
    
    var alertController: UIAlertController?
    private func createAlert(isSomeoneWin: Bool) {
        
        guard alertController == nil else {
            return
        }
        
        var text = ""
        if isSomeoneWin {
            text =  (isFirstPlayerTurn ? "Red" : "Blue")  + " player win!"
        }

        alertController = UIAlertController(title: "Game over",
                                                message: "\(text) Restart the game?",
            preferredStyle: .alert)
        
        // Create Ok button
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (result: UIAlertAction) in self.restartGame()
        }
        alertController?.addAction(okAction)
        
        // FIXME: Cancel
        // Create Cancel button
        alertController?.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) {
                (action: UIAlertAction!) in print("Cancel button tapped")
        })
        self.present(alertController!, animated: true, completion: nil)
    }

    
    //================================================================================================
    // MARK: - Inner Methods
    
    // restart the game
    private func restartGame() {
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                let ball = arrayBallViews[row][col]
                ball.setPlayer(player: .none)
            }
        }
        alertController = nil
        isFirstPlayerTurn = true
        countTurn = 0
        self.title = (isFirstPlayerTurn ? "Red" : "Blue") + " player"
    }
    
    
    // calculate balls size
    // calculate amount of rows
    private func configureGeometryParameters() {
        
        // calculate balls size from the width
        Sizes.BallSize = ((self.view.bounds.width - Sizes.Inset) / CGFloat(Sizes.COLS)) - Sizes.Inset
        
        // calculate amount of rows from the balls size
        let navBarHeight: CGFloat = self.navigationController?.navigationBar.frame.size.height ?? 0
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let availableHeight = self.view.bounds.height - navBarHeight - statusBarHeight
        
        let amountRows = (availableHeight - Sizes.Inset) / (Sizes.BallSize + Sizes.Inset)

        Sizes.ROWS = Int(floor(amountRows))
        
        let size = CGSize(width: self.view.bounds.width,
                          height: CGFloat(Sizes.ROWS) * (Sizes.BallSize + Sizes.Inset) + Sizes.Inset)
        
        fieldView.frame = CGRect(x: 0,
                                      y: statusBarHeight + navBarHeight + (availableHeight - size.height) / 2,
                                      width: size.width,
                                      height: size.height)
        
        self.fieldView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0)
        configureBallsArray()
    }
    
    // create array of custom views
    private func configureBallsArray()  {
        arrayBallViews = [] // clear array before filling it
        
        for row in 0..<Sizes.ROWS {
            var arrBallViews = [BallView]()
            for col in 0..<Sizes.COLS {
                let ball = Ball(point: CGPoint(x: (Sizes.Inset + Sizes.BallSize) * CGFloat(col) + Sizes.Inset,
                                               y: (Sizes.Inset + Sizes.BallSize) * CGFloat(row) + Sizes.Inset),
                                position: Position(row: row, col: col))
                
                let ballView = BallView(currentBall: ball)
                ballView.frame = CGRect(origin: ball.point,
                                        size: CGSize(width: ball.size, height: ball.size))
                fieldView.addSubview(ballView)
                arrBallViews.append(ballView)
            }
            arrayBallViews.append(arrBallViews)
        }
    }
    
    // create tag gesture recognizer
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        tapGestureRecognizer.delegate = self
        self.fieldView.isUserInteractionEnabled = true
        self.fieldView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // method for tapGestureRecognizer
    @objc private func tapAction(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self.fieldView)
        handleTouch(touchPoint)
    }
    
    // implement user's tap on the field and adding the ball
    private func handleTouch(_ touchPoint: CGPoint) {
        
        let col = Int(touchPoint.x / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        let row = Int(touchPoint.y / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        
        // check if tap was outside the amount of ROWS/COLS
        if row >= Sizes.ROWS || col >= Sizes.COLS { return }
        
        guard let rowForSet = getLastFreeRow(tappedRow: row, tappedCol: col) else {
            print("can't set")
            return
        }

        // show the ball on the field
        let ballView = arrayBallViews[rowForSet][col]
        
        ballView.setPlayer(player: isFirstPlayerTurn ? .first : .second)
        
        // check for winner
        checkForWin(countTurn, row: rowForSet, col: col)
        
        // change the turn in the game
        isFirstPlayerTurn = !isFirstPlayerTurn
        
        // show the turn in title NavBar
        self.title = (isFirstPlayerTurn ? "Red" : "Blue") + " player"
        countTurn += 1
    }

    // find the row which ball should be set
    private func getLastFreeRow(tappedRow: Int, tappedCol: Int) -> Int? {
        
        var rowForBall: Int? = nil
        
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

