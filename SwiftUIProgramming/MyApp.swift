import SwiftUI
import OSLog

@main
struct MyApp: App {

    let logger = Logger()
    let storage = Storage()
    @State var model: ContentViewStore.Model? = nil
    @State var yOffset: CGFloat = 0.0
    @State var isSplashScreenExists: Bool = true
    @State var deeplinkingPhotoID: UUID?

    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                ZStack {
                    if let model {
                        ContentView(
                            store: ContentViewStore(
                                model: model,
                                storage: storage
                            ),
                            deeplinkingPhotoID: deeplinkingPhotoID
                        )
                    }
                    if isSplashScreenExists {
                        SplashScreen()
                            .animation(.linear(duration: 0.5).delay(2.25), value: yOffset)
                            .onAppear {
                                yOffset = -proxy.size.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom
                                Task {
                                    let selectedPhoto = await storage.getSelectedPhoto()
                                    let transformedPhotos = await storage.getPhotos()
                                    self.model = .init(
                                        selectedPhoto: selectedPhoto,
                                        transformedPhotos: transformedPhotos
                                    )
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.75) {
                                    isSplashScreenExists = false
                                }
                            }
                            .offset(y: yOffset)
                    }
                }
            }
            .onOpenURL { url in
                guard
                    let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
                    let photoId = queryItems.first(where: { $0.name == "photo_id" })?.value
                else { return }
                self.deeplinkingPhotoID = UUID(uuidString: photoId)
                print(deeplinkingPhotoID)
            }
        }
    }

}
