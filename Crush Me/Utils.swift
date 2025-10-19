//
//  Utils.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import SwiftUI

enum IconType: CaseIterable, Equatable {
    
    case empty
    case triangle
    case circle
    case square
    case heart
    case row
    case column
    case bang
    case gift
    case bomb
    
    var color: Color {
        switch self {
        case .empty:
                .clear
        case .triangle:
                .orange
        case .circle:
                .yellow
        case .square:
                .green
        case .heart:
                .red
        case .row:
                .blue
        case .column:
                .pink
        case .bang:
                .indigo
        case .gift:
                .teal
        case .bomb:
                .purple
        }
    }
    
    var name: String {
        switch self {
        case .empty:
            ""
        case .triangle:
            "triangle.fill"
        case .circle:
            "circle.fill"
        case .square:
            "square.fill"
        case .heart:
            "heart.fill"
        case .row:
            "arrowshape.left.arrowshape.right.fill"
        case .column:
            "arrow.up.arrow.down.circle"
        case .bang:
            "dot.radiowaves.left.and.right"
        case .gift:
            "ladybug.fill"
        case .bomb:
            "BombIcon"
        }
    }
    
    
    var isCustomImage: Bool {
            switch self {
            case .bomb:
                return true
            default:
                return false
            }
        }
    
    
    static func random () -> IconType {
        let allCases = self.core()
        let randomIndex = Int.random(in: 0..<allCases.count)
        return allCases[randomIndex]
    }
    
    static func core()-> [IconType]{
        return[.circle,.triangle,.square,.heart]
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.bold()
            .scaleEffect(configuration.isPressed ? 1.4: 1)
            .animation(.spring, value: configuration.isPressed)
    }
}
