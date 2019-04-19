//
//  GolfGameExtension.swift
//  Golf Counter
//
//  Created by Aaron Sears on 4/5/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import Foundation

extension GolfGame {
    
    func initializeGolfGame() {
        puttCount = []
        strokeCount = []
        parCount = []
    }
    
    func createNewGame(holes: Int) {
        dateCreated = Date()
        isActive = true
        var hole = 0
        while hole < holes {
            puttCount?.append(0)
            strokeCount?.append(0)
            parCount?.append(0)
            hole += 1
        }
    }
}
