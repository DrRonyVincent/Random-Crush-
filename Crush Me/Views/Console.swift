//
//  Console.swift
//  Crush Me
//
//  Created by Rony Vincent on 18/10/25.
//

import SwiftUI

struct Console: View {
    
    var game: GameVM
    var body: some View {
        HStack(spacing:8){
            VStack{
                Text("Score")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("\(game.score)")
                    .bold()
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .padding(.vertical,8)
            .frame(maxWidth: .infinity)
            .background(.blue.gradient)
            .cornerRadius(10)
            
            VStack{
                Text("Best Score")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("\(game.bestScore)")
                    .bold()
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .padding(.vertical,8)
            .frame(maxWidth: .infinity)
            .background(.blue.gradient)
            .cornerRadius(10)
            
        }
    }
}


