import Foundation
import UIKit

struct ContentViewState {
    var selectedPhoto: UIImage?
    var transformedPhotos: [(offset: Int, element: UIImage)] = []
}
