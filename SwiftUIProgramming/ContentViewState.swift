import Foundation
import UIKit

struct ContentViewState {
    struct TransformedPhoto: Identifiable, Hashable {
        enum Content: Hashable {
            case processing(Double)
            case image(UIImage)
        }
        let content: Content
        let id: UUID
    }

    var selectedPhoto: UIImage?
    var transformedPhotos: [TransformedPhoto] = []
}
