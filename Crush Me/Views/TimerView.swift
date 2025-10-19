//
//  TimerView.swift
//  Crush Me
//
//  Created by Rony Vincent on 18/10/25.
//
import SwiftUI

struct TimerView: View {
    var game: GameVM
    var geo: GeometryProxy
    var body: some View {
        ZStack(alignment: .leading){
            Capsule()
                .frame(height: 41)
            Capsule()
                .frame(maxWidth: (geo.size.width-32) * CGFloat(Double(game.gameTime)/60))
                .frame(height: 40)
                .foregroundStyle(Color.blue.gradient)
                .overlay(alignment: .trailing){
                    if game.gameTime > 5 {
                        Text("\(game.gameTime)")
                            .bold()
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding(.trailing,4)
                    }
                }
        }
    }
}


