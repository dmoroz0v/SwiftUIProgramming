//
//  DetailsView.swift
//  SwiftUIProgramming
//
//  Created by Denis S. Morozov on 19.12.2023.
//

import Foundation
import SwiftUI


struct DetailsView: View {
    @ObservedObject var store: ContentViewStore
    var index: Int
    var body: some View {
        switch store.state.transformedPhotos[index].content {
        case let .image(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        case .processing(let percent):
            HStack {
                ProgressView(value: percent)
            }
        }
    }
}
