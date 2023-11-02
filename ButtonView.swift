//
//  ButtonView.swift
//  SwiftUIProgramming
//
//  Created by Denis S. Morozov on 02.11.2023.
//

import Foundation
import SwiftUI

struct ButtonView: View {
    let title: String
    let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}
