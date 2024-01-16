import SwiftUI

struct SplashScreen: View {

    @State var whiteTakesAllHorizontalSpace = false

    var body: some View {
        VStack(spacing: 0) {
            Color.yellow
            HStack(spacing: 0) {
                VStack {
                    Color.white
                    Text("YandexGo")
                        .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                Color.black
                    .frame(maxWidth: whiteTakesAllHorizontalSpace ? .zero : .infinity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 0.25).delay(2)) {
                whiteTakesAllHorizontalSpace = true
            }
        }
    }

}
