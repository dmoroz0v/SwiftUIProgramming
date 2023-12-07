import SwiftUI

struct SplashScreen: View {

    @State var whiteTakesAllHorizontalSpace = false
    @State var whiteTakesAllVerticalSpace = false

    var body: some View {
        VStack(spacing: 0) {
            Color.yellow
                .frame(maxHeight: whiteTakesAllVerticalSpace ? .zero : .infinity)
            HStack(spacing: 0) {
                Color.white
                    .frame(maxHeight: whiteTakesAllVerticalSpace ? .zero : .infinity)
                    .frame(maxWidth: .infinity)
                Color.black
                    .frame(maxWidth: whiteTakesAllHorizontalSpace ? .zero : .infinity)
            }
            Color.clear
                .frame(maxHeight: whiteTakesAllVerticalSpace ? .infinity : .zero)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 0.25).delay(2)) {
                whiteTakesAllHorizontalSpace = true
            }
            withAnimation(.linear(duration: 0.25).delay(2.5)) {
                whiteTakesAllVerticalSpace = true
            }
        }
    }

}
