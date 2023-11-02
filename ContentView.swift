import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photo: UIImage? = nil
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SquareView() {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        if let photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Text("Select Image")
                        }
                    }
                    .padding(.horizontal, 16)
                    .onChange(of: photoItem) { _ in
                        Task {
                            if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                                photo = UIImage(data: data)
                            }
                        }
                    }

                }
                SquareView() {
                    VStack {
                        ButtonView("Rotate") {
                            print("1")
                        }
                        ButtonView("Invert Colors") {
                            print("2")
                        }
                        ButtonView("Mirror") {
                            print("3")
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            Spacer()
        }
    }
}
