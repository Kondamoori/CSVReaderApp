//
//  ShimmerViewModifier.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import SwiftUI

struct ShimmerViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.gray, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase * 350, y: 0)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerViewModifier())
    }
}
