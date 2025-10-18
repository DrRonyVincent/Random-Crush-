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
                .foregroundStyle(Color(red: 242, green: 225, blue: 213))
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay{
                    if game.board[row][col] != .empty {
                        Image(systemName:  (game.board[row][col].name))
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(game.board[row][col].Color)
                            .shadow(radius: 3)
                            .padding(4)
                    }
                }
        }
        .buttonStyle(CustomButtonStyle())
    }
}

