import Foundation
import UIKit

actor Storage {

    func save(selectedPhoto: UIImage?) throws {
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let transformedImagesUrl = URL(fileURLWithPath: appDir[0]).appendingPathComponent("transformedImages")
        if FileManager.default.fileExists(atPath: transformedImagesUrl.appending(component: "selectedImage.png").path()) {
            try FileManager.default.removeItem(at: transformedImagesUrl.appending(component: "selectedImage.png"))
        } else {
            try FileManager.default.createDirectory(at: transformedImagesUrl, withIntermediateDirectories: true)
        }
        if let selectedPhoto {
            try selectedPhoto.pngData()?.write(to: transformedImagesUrl.appending(component: "selectedImage.png"), options: .atomic)
        }
    }

    func getSelectedPhoto() -> UIImage? {
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let transformedImagesUrl = URL(fileURLWithPath: appDir[0]).appendingPathComponent("transformedImages")
        do {
            let data = try Data(contentsOf: transformedImagesUrl.appending(component: "selectedImage.png"))
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
