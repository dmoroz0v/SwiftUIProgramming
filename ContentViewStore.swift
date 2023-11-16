import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

@MainActor
class ContentViewStore: ObservableObject {

    struct Model {
        var selectedPhoto: UIImage?
        var transformedPhotos: [UIImage] = []
    }

    @Published var photoItem: PhotosPickerItem? = nil
    @Published var state: ContentViewState = ContentViewState()

    private var model: Model = Model() {
        didSet { updateState() }
    }

    private var cancelables: Set<AnyCancellable> = []

    init() {
        $photoItem.sink { photoItem in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    self.model.selectedPhoto = UIImage(data: data)
                }
            }
        }
        .store(in: &cancelables)
    }

    func rotate() {
        guard let photo = model.selectedPhoto else { return }
        let rotated = UIGraphicsImageRenderer(
            size: .init(width: photo.size.height, height: photo.size.width)
        ).image { context in
            context.cgContext.translateBy(x: photo.size.height, y: 0)
            context.cgContext.rotate(by: .pi/2)
            photo.draw(at: .zero)
        }
        self.model.transformedPhotos.append(rotated)
    }

    private func updateState() {
        state = .init(
            selectedPhoto: model.selectedPhoto,
            transformedPhotos: model.transformedPhotos.enumerated().reversed()
        )
    }
}
