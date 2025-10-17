//
//  GameVM.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import Foundation
import SwiftUI


@Observable

class GameVM {
    var score = 0
    var combo = 0
    var isMatch = false
    var isProcessing = false
    var gameTime = 30
    var isPlaying = false
    var isStop = false
    var timer: Timer?
    var isGameOver = false
    var rows = 8
    var columns = 8
    var board: [[IconType]] = Array(repeating: Array(repeating: IconType.empty, count: 8), count: 8)
 
    func fillGrid (){
        for row in 0..<rows {
            for col in 0..<columns {
                withAnimation(.easeInOut(duration: 0.3)){
                    board[row][col] = IconType.random()
                }
            }
        }
    }
    
    func preventInitialMatches (){
        for row in 0..<rows{
            for col in 0..<columns{
                var currentType = board[row][col]
                
                if col >= 2 {
                    if board[row][col-1] == currentType && board[row][col-2] == currentType {
                        let newType = IconType.core().first{
                            $0 != currentType
                        }
                        board[row][col] = newType ?? .empty
                        currentType = newType ?? .empty
                    }
                }
                if row >= 2 {
                    if board[row-1][col] == currentType && board[row-2][col] == currentType {
                        let newType = IconType.core().first{
                            $0 != currentType
                        }
                        board[row][col] = newType ?? .empty
                        currentType = newType ?? .empty
                    }
                }
            }
        }
    }
    
    func setupBoard (){
        self.board =  Array(repeating: Array(repeating: IconType.empty, count: 8), count: 8)
        withAnimation(.easeInOut(duration: 0.3)){
            fillGrid()
            preventInitialMatches()
        }
    }
    
    func gameStart () {
        self.score = 0
        self.gameTime = 30
        isPlaying = true
        
        setupBoard()
    }
}

