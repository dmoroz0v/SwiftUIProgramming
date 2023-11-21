import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

@MainActor
class ContentViewStore: ObservableObject {

    struct Model {
        struct TransformedPhoto: Identifiable, Hashable {
            enum Content: Hashable {
                case processing
                case image(original: UIImage, thumbnail: UIImage)
            }
            let content: Content
            let id: Int
        }

        var selectedPhoto: UIImage?
        var transformedPhotos: [TransformedPhoto] = []
    }

    actor ImageProccessor {

        func rotate(_ image: UIImage) async throws -> UIImage {
            try await Task.sleep(nanoseconds: UInt64.random(in: 1..<3) * 1_000_000_000)
            return UIGraphicsImageRenderer(
                size: .init(width: image.size.height, height: image.size.width)
            ).image { context in
                context.cgContext.translateBy(x: image.size.height, y: 0)
                context.cgContext.rotate(by: .pi/2)
                image.draw(at: .zero)
            }
        }

        func generateThumbnail(_ image: UIImage) async throws -> UIImage {
            let orgSize = image.size
            let size = CGSize(width: orgSize.width * 0.2, height: orgSize.height * 0.2)
            let imgRect = CGRect(origin: .zero, size: size)
            return UIGraphicsImageRenderer(size: size).image { ctx in
                UIBezierPath(roundedRect: imgRect, cornerRadius: 12).addClip()
                image.draw(in: imgRect)
            }
        }

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
        model.transformedPhotos.append(.init(content: .processing, id: index))

        Task {
            let processor = ImageProccessor()
            let rotated = try await processor.rotate(photo)
            let thumnail = try await processor.generateThumbnail(rotated)
            self.model.transformedPhotos[index] = .init(
                content: .image(original: rotated, thumbnail: thumnail),
                id: index
            )
        }
    }

    private func updateState() {
        state = .init(
            selectedPhoto: model.selectedPhoto,
            transformedPhotos: model.transformedPhotos.map {
                let photo: ContentViewState.TransformedPhoto.Content
                switch $0.content {
                case let .image(_, thumbnail):
                    photo = .image(thumbnail)
                case .processing:
                    photo = .processing
                }
                return ContentViewState.TransformedPhoto(
                    content: photo,
                    id: $0.id
                )
            }.reversed()
        )
    }
}
