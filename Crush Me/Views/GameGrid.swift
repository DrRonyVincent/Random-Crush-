//
//  GameGrid.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import SwiftUI

struct GameGrid: View {
    
    var game: GameVM
    var body: some View {
        LazyVGrid (columns: Array(repeating: GridItem(spacing: 4), count: 8)){
            ForEach (0..<game.rows){ row in
                ForEach (0..<game.columns){ col in
                    GeometryReader { geo in
                    GameButton(
                        row: row, col: col, game: game, geo: geo
                    )}
                    .aspectRatio(contentMode: .fit)
                    
                }
            }
        }
        .padding(12)
        .background(.purple)
        .overlay {
            Button(action: {
                game.gameStart()
            }){
                Text("Game start")
                    .bold()
                    .font(.largeTitle)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.purple)
                    .cornerRadius(12)
            }
        }
        
    }
}

#Preview {
    GameGrid(game: GameVM())
}
