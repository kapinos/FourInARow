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
    case none   = ""
}


struct Sizes {
    static var BallSize: CGFloat    = -1
    static let Inset: CGFloat       = 1
    static let COLS                 = 6
    static var ROWS                 = -1
    static let AmountBallsForWin    = 4
}

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    var arrayBallViews: [[BallView]] = []
    var fieldView = UIView()
    var isFirstPlayerTurn = true

    // MARK: - IBOutlets
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(fieldView)
        
        configureTapGestureRecognizer()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureGeometryParameters()
    }
    
    //================================================================================================
    // Detect winner Logic
    //-----------------------
    // 1 variant
    //-----------------------
    private func checkForWin1(_ countTurn: Int) {
        let currentPlayer: Player = isFirstPlayerTurn ? Player.first : Player.second
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                if arrayBallViews[row][col].player != currentPlayer {
                    continue
                } else {
                    print("turn: \(countTurn)")
                    // →
                    var arraySumm = 0
                    for c in col..<Sizes.COLS {
                        if arrayBallViews[row][c].player != currentPlayer {
                            arraySumm = 0
                            break
                        } else {
                            arraySumm += 1
                            print("→ row:\(row) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm)")
                            if isPlayerWin(currentSumm: arraySumm) { return }
                        }
                    }
                    // ↓
                    arraySumm = 0
                    for r in row..<Sizes.ROWS {
                        if arrayBallViews[r][col].player != currentPlayer {
                            arraySumm = 0
                            break
                        } else {
                            arraySumm += 1
                            print("↓ row:\(r) col:\(col) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm)")
                            if isPlayerWin(currentSumm: arraySumm) { return }
                        }
                    }
                    // ↘
                    arraySumm = 0
                    for i in 0..<min(Sizes.ROWS,Sizes.COLS) {
                        let c = col + i
                        let r = row + i
                        if !verifyCoordinate(row: r, col: c) {
                            break
                        }
                        if arrayBallViews[r][c].player != currentPlayer {
                            arraySumm = 0
                            break
                        } else {
                            arraySumm += 1
                            print("↘ row:\(r) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm)")
                            if isPlayerWin(currentSumm: arraySumm) { return }
                        }
                    }
                    // ↙
                    arraySumm = 0
                    for i in 0..<min(Sizes.ROWS,Sizes.COLS) {
                        let c = col - i
                        let r = row + i
                        if !verifyCoordinate(row: r, col: c) {
                            break
                        }
                        if arrayBallViews[r][c].player != currentPlayer {
                            arraySumm = 0
                            break
                        } else {
                            arraySumm += 1
                            print("↙ row:\(r) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm)")
                            if isPlayerWin(currentSumm: arraySumm) { return }
                        }
                    }
                }
            }
        }
    }
    
    //-----------------------
    // 2 variant
    //-----------------------
//    private func checkForWin2(_ countTurn: Int, _ row: Int, _ col: Int) {
//        let currentPlayer: Player = isFirstPlayerTurn ? Player.first : Player.second
//        // →
//        let startCol = min(0, col - Sizes.AmountBallsForWin)
//        let endCol   = min(Sizes.COLS, col + Sizes.AmountBallsForWin)
//        var arraySumm = 0
//        for c in startCol..<endCol {
//            if arrayBallViews[row][c].player != currentPlayer {
//                arraySumm = 0
//            } else {
//                arraySumm += 1
//                print("→ row:\(row) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm)")
//                if isPlayerWin(currentSumm: arraySumm) { return }
//            }
//
//        }
//        // ↓
//        // ↘
//        // ↙
//
//    }
    
    func verifyCoordinate(row: Int, col: Int) -> Bool {
        if row < 0 || row >= Sizes.ROWS { return false }
        if col < 0 || col >= Sizes.COLS { return false }
        return true
    }
    
    private func isPlayerWin(currentSumm: Int) -> Bool {
        if currentSumm == Sizes.AmountBallsForWin {
            createAlert()
            return true
        }
        return false
    }
    
    
    
    
    
    
    //================================================================================================
    // MARK: - Inner Methods
    
    private func createAlert() {
        let nameWinner = (isFirstPlayerTurn ? "Red" : "Blue") + " player"
        let alertController = UIAlertController(title: "Game over",
                                                message: "\(nameWinner) win! Restart the game?",
            preferredStyle: .alert)
        
        // Create Ok button
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (result: UIAlertAction) in self.restartGame()
        }
        alertController.addAction(okAction)
        
        // Create Cancel button
        alertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) {
                (action: UIAlertAction!) in print("Cancel button tapped")
        })
        self.present(alertController, animated: true, completion: nil)
    }

    // restart the game
    private func restartGame() {
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                let ball = arrayBallViews[row][col]
                ball.setPlayer(player: .none)
            }
        }
        isFirstPlayerTurn = true
        countTurn = 0
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
        //print("amountRows: \(amountRows)")  // LOG
        Sizes.ROWS = Int(floor(amountRows))
        
        let size = CGSize(width: self.view.bounds.width,
                          height: CGFloat(Sizes.ROWS) * (Sizes.BallSize + Sizes.Inset) + Sizes.Inset)
        
        //print("self.view.height: \(self.view.bounds.height)\nnavBar: \(navBarHeight)\nstatusBar: \(statusBarHeight)\navailableHeight: \(availableHeight)\nsize.height: \(size.height)\nshift: \(shift)") // LOG
        
        fieldView.frame = CGRect(x: 0,
                                      y: statusBarHeight + navBarHeight + (availableHeight - size.height) / 2,
                                      width: size.width,
                                      height: size.height)
        
        self.fieldView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0)
        //print("ballSize = \(Sizes.BallSize), rows = \(Sizes.ROWS)\nwidth=\(self.fieldView.bounds.width), height=\(self.fieldView.bounds.height)") // LOG
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
    var countTurn = 0
    private func handleTouch(_ touchPoint: CGPoint) {
        
        //print("x: \(touchPoint.x), y: \(touchPoint.y)") // LOG
        
        let col = Int(touchPoint.x / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        let row = Int(touchPoint.y / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        
        //print("col: \(col), row: \(row)") // LOG

        // check if tap was outside the amount of ROWS/COLS
        if row >= Sizes.ROWS || col >= Sizes.COLS { return }
        
        let rowForSet = getLastFreeRow(tappedRow: row, tappedCol: col)

        // show the ball on the field
        let ballView = arrayBallViews[rowForSet][col]
        
        ballView.setPlayer(player: isFirstPlayerTurn ? .first : .second)
        
        //============================
        // check for winner
        checkForWin1(countTurn)             // variant 1
        //checkForWin2(countTurn, row, col) // variant 2
        countTurn += 1
        //============================
        
        // change the turn in the game
        isFirstPlayerTurn = !isFirstPlayerTurn
    }

    // find the row which ball should be set
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

