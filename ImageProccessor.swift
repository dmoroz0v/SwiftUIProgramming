import Foundation
import UIKit

final class ImageProccessor {

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
