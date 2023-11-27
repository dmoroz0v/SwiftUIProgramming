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

    private let imageProcessor = ImageProccessor()
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

    func updateSelectedPhoto(at index: Int) {
        if case let .image(original, _) = model.transformedPhotos[index] {
            model.selectedPhoto = original
        }
    }

    func rotate() {
        guard let photo = model.selectedPhoto else { return }
        let index = model.transformedPhotos.endIndex
        model.transformedPhotos.append(.processing)

        Task {
            let rotated = try await self.imageProcessor.rotate(photo)
            let thumbnail = try await self.imageProcessor.generateThumbnail(rotated)
            self.model.transformedPhotos[index] = .image(
                original: rotated,
                thumbnail: thumbnail
            )
        }
    }

    func invertColors() {
        guard let photo = model.selectedPhoto else { return }
        let index = model.transformedPhotos.endIndex
        model.transformedPhotos.append(.processing)

        Task {
            let invertedImage = try await self.imageProcessor.invertColors(photo)
            let thumbnail = try await self.imageProcessor.generateThumbnail(invertedImage)
            self.model.transformedPhotos[index] = .image(
                original: invertedImage,
                thumbnail: thumbnail
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
