import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

class ContentViewStore: ObservableObject {
    @Published var photoItem: PhotosPickerItem? = nil

    @Published var state: ContentViewState = ContentViewState()

    private var photo: UIImage? = nil {
        didSet {
            updateState()
        }
    }
    private var cancelables: Set<AnyCancellable> = []

    init() {
        $photoItem.sink { photoItem in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.photo = UIImage(data: data)
                    }
                }
            }
        }
        .store(in: &cancelables)
    }

    func rotate() {
        guard let photo, let img = CIImage(image: photo) else {
            return
        }
        self.photo = UIImage(ciImage: img.oriented(.right))
    }

    private func updateState() {
        state = .init(photo: photo)
    }
}
