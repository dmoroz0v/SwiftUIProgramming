import SwiftUI
import PhotosUI
import Combine

struct ContentView: View {

    @ObservedObject var store: ContentViewStore

    enum NavPathItem: Hashable {
        case details(Int)
    }

    @State private var navPath: [NavPathItem] = []

    var body: some View {
        NavigationStack(path: $navPath) {
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
                            TransformedImagePreview(photo: photo) { id in
                                store.updateSelectedPhoto(at: id)
                            }
                        }
                        .frame(height: 100)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationDestination(for: NavPathItem.self) { pathItem in
                switch pathItem {
                case .details(let photoId):
                    DetailsView(store: store, photoId: photoId) {
                        navPath.removeAll()
                    }
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

    let photo: ContentViewState.TransformedPhoto
    let onPhotoSelectAction: ((Int) -> Void)

    var body: some View {
        switch photo.content {
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
                    presenting: photo
                ) { photo in
                    Button {
                        onPhotoSelectAction(photo.id)
                    } label: {
                        Text("Transform")
                    }
                    NavigationLink(value: ContentView.NavPathItem.details(photo.id)) {
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
                presenting: photo
            ) { photo in
                NavigationLink(value: ContentView.NavPathItem.details(photo.id)) {
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
