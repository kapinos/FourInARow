//
//  BallView.swift
//  FourInARow
//
//  Created by Anastasia on 11/9/17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit

class BallView: UIImageView {

    private(set) var ball: Ball
    private(set) var player: Player
    
    init(currentBall: Ball) {
        
        ball = currentBall
        player = Player.none
    
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changePlayer(player: Player) {
        self.player = player
    }
}
