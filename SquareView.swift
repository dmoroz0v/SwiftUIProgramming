//
//  SquareView.swift
//  SwiftUIProgramming
//
//  Created by Denis S. Morozov on 02.11.2023.
//

import Foundation
import SwiftUI

struct SquareView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        ZStack {
            content()
        }
        .contentShape(Rectangle())
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .aspectRatio(1, contentMode: .fit)
    }
}
