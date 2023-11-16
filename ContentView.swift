import SwiftUI
import PhotosUI
import Combine

struct ContentView: View {

    @ObservedObject var store = ContentViewStore()

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                SquareView() {
                    PhotosPicker(selection: $store.photoItem, matching: .images) {
                        if let photo = store.state.selectedPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Text("Select Image")
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                        }
                    }
                }
                SquareView() {
                    VStack {
                        ButtonView("Rotate") {
                            store.rotate()
                        }
                        ButtonView("Invert Colors") {
                            print("2")
                        }
                        ButtonView("Mirror") {
                            print("3")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            ScrollView {
                VStack {
                    ForEach(store.state.transformedPhotos, id: \.offset) { offset, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
