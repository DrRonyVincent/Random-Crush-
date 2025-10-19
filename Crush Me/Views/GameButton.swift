//
//  GameButton.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import SwiftUI

struct GameButton: View {
    
    let row: Int
    let col: Int
    let game: GameVM
    let geo: GeometryProxy
    
    var body: some View {
        Button (action: {
            game.tryProcess(row: row, col: col)
        }){
            Rectangle()
                .frame(width: nil, height: geo.size.width)
                .foregroundStyle(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .overlay{
                    let iconType = game.board[row][col]
                    if iconType != .empty {
                        
                        if iconType.isCustomImage {
                            Image(iconType.name)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100, maxHeight: 100)
                        }else
                        {
                            Image(systemName:  (game.board[row][col].name))
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(game.board[row][col].color)
                                .shadow(radius: 3)
                                .padding(4)
                        }
                    }
                }
        }
        .buttonStyle(CustomButtonStyle())
    }
}

