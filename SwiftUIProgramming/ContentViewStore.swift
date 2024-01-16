import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

@MainActor
class ContentViewStore: ObservableObject {

    let storage: Storage

    struct Model {
        enum TransformedPhoto {
            case processing(percent: Double, uuid: UUID)
            case image(original: UIImage, thumbnail: UIImage, uuid: UUID)

            var uuid: UUID {
                switch self {
                case .processing(_, let uuid):
                    return uuid
                case .image(_, _, let uuid):
                    return uuid
                }
            }
        }

        var selectedPhoto: UIImage?
        var transformedPhotos: [TransformedPhoto] = []
    }

    @Published var photoItem: PhotosPickerItem? = nil
    @Published var state: ContentViewState = ContentViewState()

    private var model: Model {
        didSet {
            updateState()
            Task {
                try await self.storage.save(photos: model.transformedPhotos)
            }
        }
    }

    private let imageProcessor = ImageProccessor()
    private var cancelables: Set<AnyCancellable> = []

    init(model: Model, storage: Storage) {
        self.model = model
        self.storage = storage
        $photoItem.sink { photoItem in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    self.model.selectedPhoto = UIImage(data: data)
                    do {
                        try await self.storage.save(selectedPhoto: self.model.selectedPhoto)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .store(in: &cancelables)
        updateState()
    }

    func updateSelectedPhoto(with uuid: UUID) {
        if case let .image(original, _, _) = model.transformedPhotos.first(where: { $0.uuid == uuid }) {
            model.selectedPhoto = original
            Task {
                try await self.storage.save(selectedPhoto: self.model.selectedPhoto)
            }
        }
    }

    func rotate() {
        guard let photo = model.selectedPhoto else { return }
        let uuid = UUID()
        let index = model.transformedPhotos.endIndex
        model.transformedPhotos.append(.processing(percent: 0, uuid: uuid))

        Task {
            let rotated = try await self.imageProcessor.rotate(photo) { @MainActor percent in
                var model = self.model
                model.transformedPhotos[index] = .processing(percent: percent, uuid: uuid)
                self.model = model
            }
            let thumbnail = try await self.imageProcessor.generateThumbnail(rotated)
            print(uuid)
            self.model.transformedPhotos[index] = .image(
                original: rotated,
                thumbnail: thumbnail,
                uuid: uuid
            )
        }
    }

    func invertColors() {
        guard let photo = model.selectedPhoto else { return }
        let uuid = UUID()
        let index = model.transformedPhotos.endIndex
        model.transformedPhotos.append(.processing(percent: 0, uuid: uuid))

        Task {
            let invertedImage = try await self.imageProcessor.invertColors(photo) { @MainActor percent in
                var model = self.model
                model.transformedPhotos[index] = .processing(percent: percent, uuid: uuid)
                self.model = model
            }
            let thumbnail = try await self.imageProcessor.generateThumbnail(invertedImage)
            self.model.transformedPhotos[index] = .image(
                original: invertedImage,
                thumbnail: thumbnail,
                uuid: uuid
            )
        }
    }

    private func updateState() {
        state = .init(
            selectedPhoto: model.selectedPhoto,
            transformedPhotos: model.transformedPhotos.enumerated().map { index, item in
                let photo: ContentViewState.TransformedPhoto.Content
                let uuid: UUID
                switch item {
                case let .image(_, thumbnail, _uuid):
                    photo = .image(thumbnail)
                    uuid = _uuid
                case let .processing(percent, _uuid):
                    photo = .processing(percent)
                    uuid = _uuid
                }
                return ContentViewState.TransformedPhoto(
                    content: photo,
                    id: uuid
                )
            }.reversed()
        )
    }
}
