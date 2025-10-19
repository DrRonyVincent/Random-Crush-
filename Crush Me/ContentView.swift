//
//  ContentView.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var game = GameVM()
    var body: some View {
        NavigationStack{
            GeometryReader{ geo in
                VStack{
                    Console(game: game)
                    TimerView(game: game, geo: geo)
                    GameGrid(game: game)
                    
                    if game.combo != 0 {
                        withAnimation(.easeInOut(duration: 0.4)){
                            Text("Combo \(game.combo)!")
                                .bold()
                                .font(.largeTitle)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(LinearGradient(colors: [Color(.green), Color(.blue)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .navigationTitle("Crush Me!")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
