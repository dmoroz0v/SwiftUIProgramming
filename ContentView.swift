import SwiftUI
import PhotosUI
import Combine

struct ContentView: View {

    @ObservedObject var store = ContentViewStore()

    @State private var isActionSheetPresented: Bool = false

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
                            store.invertColors()
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
                    ForEach(store.state.transformedPhotos) { photo in
                        switch photo.content {
                        case let .image(image):
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    isActionSheetPresented = true
                                }
                                .confirmationDialog(
                                    "Action on the image",
                                    isPresented: $isActionSheetPresented
                                ) {
                                    Button {
                                        store.updateSelectedPhoto(at: photo.id)
                                    } label: {
                                        Text("Transform")
                                    }
                                    Button("Cancel", role: .cancel) {
                                        isActionSheetPresented = false
                                    }
                                } message: {
                                    Text("What to do with the image?")
                                }
                        case .processing:
                            ProgressView()
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
