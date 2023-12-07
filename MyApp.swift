import SwiftUI

@main
struct MyApp: App {
    let storage = Storage()
    @State var model: ContentViewStore.Model? = nil
    var body: some Scene {
        WindowGroup {
            if let model {
                ContentView(store: ContentViewStore(
                    model: model,
                    storage: storage
                ))
            } else {
                ProgressView()
                    .onAppear {
                        Task {
                            let selectedPhoto = await storage.getSelectedPhoto()
                            self.model = .init(selectedPhoto: selectedPhoto, transformedPhotos: [])
                        }
                    }
            }
        }
    }
}
