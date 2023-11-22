import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

@MainActor
class ContentViewStore: ObservableObject {

    struct Model {
        enum TransformedPhoto {
            case processing
            case image(original: UIImage, thumbnail: UIImage)
        }

        var selectedPhoto: UIImage?
        var transformedPhotos: [TransformedPhoto] = []
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
        let index = model.transformedPhotos.endIndex
        model.transformedPhotos.append(.processing)

        Task {
            let processor = ImageProccessor()
            let rotated = try await processor.rotate(photo)
            let thumnail = try await processor.generateThumbnail(rotated)
            self.model.transformedPhotos[index] = .image(
                original: rotated,
                thumbnail: thumnail
            )
        }
    }

    private func updateState() {
        state = .init(
            selectedPhoto: model.selectedPhoto,
            transformedPhotos: model.transformedPhotos.enumerated().map { index, item in
                let photo: ContentViewState.TransformedPhoto.Content
                switch item {
                case let .image(_, thumbnail):
                    photo = .image(thumbnail)
                case .processing:
                    photo = .processing
                }
                return ContentViewState.TransformedPhoto(
                    content: photo,
                    id: index
                )
            }.reversed()
        )
    }
}
