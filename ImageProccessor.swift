import Foundation
import UIKit

final class ImageProccessor {

    func rotate(
        _ image: UIImage,
        progressClosure: ((Double) -> Void)
    ) async throws -> UIImage {
        try await simulateLoading(progressClosure: progressClosure)
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

    func invertColors(
        _ image: UIImage,
        progressClosure: ((Double) -> Void)
    ) async throws -> UIImage {
        try await simulateLoading(progressClosure: progressClosure)
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

    private func simulateLoading(progressClosure: ((Double) -> Void)) async throws {
        let secondsToSleep = UInt64.random(in: 200..<1000)
        for i in 0..<secondsToSleep {
            try await Task.sleep(nanoseconds: 10000000)
            progressClosure(Double(i) / Double(secondsToSleep))
        }
        try await Task.sleep(nanoseconds: 100_000_000)
    }

}
