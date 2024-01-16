import Foundation
import UIKit

actor Storage {

    private struct MetaPhoto: Codable {
        var uuid: UUID
    }

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

    func save(photos: [ContentViewStore.Model.TransformedPhoto]) throws {
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let transformedImagesUrl = URL(fileURLWithPath: appDir[0]).appendingPathComponent("transformedImages")
        var metaPhotos: [MetaPhoto] = []
        for photo in photos {
            switch photo {
            case .image(let original, let thumbnail, let uuid):
                metaPhotos.append(.init(uuid: uuid))
                let url = transformedImagesUrl.appending(component: "\(uuid).png")
                let thumbUrl = transformedImagesUrl.appending(component: "\(uuid)_thumb.png")
                if FileManager.default.fileExists(atPath: url.path()) {
                    continue
                } else {
                    try original.pngData()?.write(to: url, options: .atomic)
                    try thumbnail.pngData()?.write(to: thumbUrl, options: .atomic)
                }
            default:
                continue
            }
        }

        let data = try JSONEncoder().encode(metaPhotos)
        try data.write(to: transformedImagesUrl.appending(component: "metaPhotos.json"), options: .atomic)
    }

    func getPhotos() -> [ContentViewStore.Model.TransformedPhoto] {
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let transformedImagesUrl = URL(fileURLWithPath: appDir[0]).appendingPathComponent("transformedImages")
        guard let data = try? Data(contentsOf: transformedImagesUrl.appending(component: "metaPhotos.json")) else {
            return []
        }
        do {
            let metaPhotos = try JSONDecoder().decode([MetaPhoto].self, from: data)
            var result: [ContentViewStore.Model.TransformedPhoto] = []
            for metaPhoto in metaPhotos {
                let url = transformedImagesUrl.appending(component: "\(metaPhoto.uuid).png")
                let thumbUrl = transformedImagesUrl.appending(component: "\(metaPhoto.uuid)_thumb.png")
                let data = try Data(contentsOf: url)
                let thumbData = try Data(contentsOf: thumbUrl)
                if let image = UIImage(data: data), let thumb = UIImage(data: thumbData) {
                    result.append(.image(original: image, thumbnail: thumb, uuid: metaPhoto.uuid))
                }
            }
            return result
        } catch {
            return []
        }
    }
}
