//
//  BattleFieldViewController.swift
//  FourInARow
//
//  Created by Anastasia on 11/8/17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit


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

class BattleFieldViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    private var arrayBallViews: [[BallView]] = []
    private var fieldView = UIView()
    private var isFirstPlayerTurn = true
    private var isEndOfTheGame = false
    
    private var countTurn: Int = 0 {
        willSet {
            self.countTurnes.title = newValue == 0 ? "" : "\(newValue)"
        }
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var countTurnes: UIBarButtonItem!
    
    // MARK: - User Actions
    @IBAction private func newGameTapped(_ sender: UIBarButtonItem) {
        createAlert("")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(fieldView)
        
        // show the turn in title NavBar
        setTitleInNavigationController()
        
        configureTapGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureGeometryParameters()
    }
    
    
    // MARK: - Inner Methods
    
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
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    
    // implement user's tap on the field and adding the ball
    private func handleTouch(_ touchPoint: CGPoint) {
        if isEndOfTheGame { return }
        
        let col = Int(touchPoint.x / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        let row = Int(touchPoint.y / (CGFloat(Sizes.BallSize) + Sizes.Inset))
        
        // check if tap was outside the amount of ROWS/COLS
        if row >= Sizes.ROWS || col >= Sizes.COLS { return }
        
        guard let rowForSet = getLastFreeRow(tappedRow: row, tappedCol: col) else {
            print("can't set")
            return
        }

        //=============================================================
        let player: String = isFirstPlayerTurn ? "first" : "second"
        let imageView = UIImageView(image: UIImage(named: player)!)
        imageView.contentMode = .scaleAspectFill
        let startX = arrayBallViews[rowForSet][col].ball.point.x
        let startY = arrayBallViews[0][col].ball.point.y
        imageView.frame = CGRect(x: startX, y: startY, width: Sizes.BallSize, height: Sizes.BallSize)
        fieldView.addSubview(imageView)
        let endPoint = arrayBallViews[rowForSet][col].ball.point
        
        UIView.animate(withDuration: 0.9, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            imageView.center = CGPoint(x: endPoint.x+Sizes.BallSize/2, y:endPoint.y+Sizes.BallSize/2 )  // Ending position of the ball
        }, completion: nil)
        
        // show the ball on the field
        // let ballView = arrayBallViews[rowForSet][col]
        // ballView.setPlayer(player: isFirstPlayerTurn ? .first : .second)
        //=============================================================
        
        
        // check for winner
        checkForWin(countTurn, row: rowForSet, col: col)
        
        // change the turn in the game
        isFirstPlayerTurn = !isFirstPlayerTurn
        
        // show the turn in title NavBar
        setTitleInNavigationController()
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
    
    // set in the Navigation Controller's Title: the Turn and Color of player
    private func setTitleInNavigationController() {
        self.title = (isFirstPlayerTurn ? "Red" : "Blue") + " player"
        let textAttributes = isFirstPlayerTurn ?
            [NSAttributedStringKey.foregroundColor:UIColor.red] : [NSAttributedStringKey.foregroundColor:UIColor.blue]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    // MARK: - GameLogic
    
    // check for every possiple direction - is someone win
    private func checkForWin(_ countTurn: Int, row: Int, col: Int) {
        //print("turn: \(countTurn)")
        // →
        checkByDirection(row: row, col: col, direction: .Horizontal)
        // ↓
        checkByDirection(row: row, col: col, direction: .Vertical)
        // ↘
        checkByDirection(row: row, col: col, direction: .DiagonalToRight)
        // ↙
        checkByDirection(row: row, col: col, direction: .DiagonalToLeft)
        
        // check for free places in the field after every turn
        if isFieldOccupied() {
            isEndOfTheGame = true
            createAlert("")
        }
    }
    
    // common method for checking directions
    func checkByDirection(row: Int, col: Int, direction: Directions) {
        if isEndOfTheGame { return }
        
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
                //print("row:\(r) col:\(c) \(isFirstPlayerTurn ? "Red " : "Blue") \(arraySumm) \(direction)")
                if isPlayerWin(currentSumm: arraySumm) { return }
            }
        }
    }
    
    // check if there are left epmty places in the field
    private func isFieldOccupied() -> Bool {
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                if arrayBallViews[row][col].player == .none {
                    return false
                }
            }
        }
        return true
    }
    
    // validate coordinates are comes in field's size
    private func isValidCoordinates(row: Int, col: Int) -> Bool {
        if row < 0 || row >= Sizes.ROWS { return false }
        if col < 0 || col >= Sizes.COLS { return false }
        return true
    }
    
    // compare checksum with the verification value for win
    private func isPlayerWin(currentSumm: Int) -> Bool {
        if currentSumm == Sizes.AmountBallsForWin {
            isEndOfTheGame = true
            let winner = isFirstPlayerTurn ? "Red" : "Blue"
            createAlert(winner)
            return true
        }
        return false
    }
    
    private func createAlert(_ winner: String) {
        
        var title   = ""
        var text    = ""
        
        if !winner.isEmpty {
            title   = "\(winner) player win!"
            text    = "Restart the game?"
        } else {
            title   =  (isEndOfTheGame ? "Draw!\n" : "") + "Restart the game?"
        }
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        // Create Ok button
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self]
            (result: UIAlertAction) in
            self?.restartTheGame()
        }
        alertController.addAction(okAction)
        
        // Create Cancel button
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // restart the game
    private func restartTheGame() {
        for row in 0..<Sizes.ROWS {
            for col in 0..<Sizes.COLS {
                let ball = arrayBallViews[row][col]
                ball.setPlayer(player: .none)
            }
        }
        isEndOfTheGame = false
        isFirstPlayerTurn = true
        countTurn = 0
        setTitleInNavigationController()
    }
}

