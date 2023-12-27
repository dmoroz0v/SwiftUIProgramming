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
    var photoId: Int
    var doneAction: () -> Void
    var body: some View {
        VStack {
            switch store.state.transformedPhotos.first(where: { $0.id == photoId })?.content {
            case let .image(image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .processing(let percent):
                HStack {
                    ProgressView(value: percent)
                }
            case .none:
                EmptyView()
            }
            Button("Done") {
                doneAction()
            }
        }
    }
}
