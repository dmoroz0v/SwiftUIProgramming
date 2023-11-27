import Foundation
import UIKit

final class ImageProccessor {

    func rotate(_ image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1..<3) * 1_000_000_000)
        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1))
        return UIGraphicsImageRenderer(
            size: .init(width: image.size.height, height: image.size.width),
            format: format
        ).image { context in
            context.cgContext.translateBy(x: image.size.height, y: 0)
            context.cgContext.rotate(by: .pi/2)
            image.draw(at: .zero)
        }
    }

    func invertColors(_ image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1..<3) * 1_000_000_000)
        let beginImage = CIImage(image: image)

        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(beginImage, forKey: kCIInputImageKey)

            let context = CIContext()
            if let output = filter.outputImage,
                let cgImage = context.createCGImage(output, from: output.extent)
            {
                return UIImage(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            } else {
                throw NSError()
            }
        } else {
            throw NSError()
        }
    }

    func generateThumbnail(_ image: UIImage) async throws -> UIImage {
        let orgSize = image.size
        let size = CGSize(width: orgSize.width * 0.2, height: orgSize.height * 0.2)
        let imgRect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1))
        return UIGraphicsImageRenderer(
            size: size,
            format: format
        ).image { ctx in
            UIBezierPath(roundedRect: imgRect, cornerRadius: 12).addClip()
            image.draw(in: imgRect)
        }
    }

}
