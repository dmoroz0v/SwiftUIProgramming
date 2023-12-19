import SwiftUI
import PhotosUI
import Combine

struct ContentView: View {

    @ObservedObject var store: ContentViewStore

    var body: some View {
        NavigationStack {
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
                        ForEach(Array(store.state.transformedPhotos.enumerated()), id: \.element.id) { index, photo in
                            TransformedImagePreview(store: store, index: index) { id in
                                store.updateSelectedPhoto(at: id)
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

    init(store: ContentViewStore) {
        self.store = store
    }
}

struct TransformedImagePreview: View {

    @State var isPresenting: Bool = false

    @ObservedObject var store: ContentViewStore
    let index: Int
    let onPhotoSelectAction: ((Int) -> Void)

    var body: some View {
        switch store.state.transformedPhotos[index].content {
        case let .image(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    isPresenting = true
                }
                .confirmationDialog(
                    "Action on the image",
                    isPresented: $isPresenting,
                    presenting: store.state.transformedPhotos[index]
                ) { photo in
                    Button {
                        onPhotoSelectAction(photo.id)
                    } label: {
                        Text("Transform")
                    }
                    NavigationLink {
                        DetailsView(store: store, index: index)
                    } label: {
                        Text("View")
                    }
                    Button("Cancel", role: .cancel) {
                       isPresenting = false
                    }
                } message: { _ in
                    Text("What to do with the image?")
                }
        case .processing(let percent):
            HStack {
                ProgressView(value: percent)
            }
            .onTapGesture {
                isPresenting = true
            }
            .confirmationDialog(
                "Action on the image",
                isPresented: $isPresenting,
                presenting: store.state.transformedPhotos[index]
            ) { photo in
                NavigationLink {
                    DetailsView(store: store, index: index)
                } label: {
                    Text("View")
                }
                Button("Cancel", role: .cancel) {
                   isPresenting = false
                }
            } message: { _ in
                Text("What to do with the image?")
            }
        }

    }
}
