//
//  MinimalisticButtonStyle.swift
//  unblur
//
//  Created by Jose Braz on 06/01/2025.
//

import SwiftUI

struct MinimalisticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)  // Makes the button full width
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.white)
            .foregroundColor(.gray)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}
