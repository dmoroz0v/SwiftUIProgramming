import Foundation
import UIKit

struct ContentViewState {
    struct TransformedPhoto: Identifiable, Hashable {
        enum Content: Hashable {
            case processing
            case image(UIImage)
        }
        let content: Content
        let id: Int
    }

    var selectedPhoto: UIImage?
    var transformedPhotos: [TransformedPhoto] = []
}
