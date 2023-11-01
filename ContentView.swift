import SwiftUI

struct SquareView<Content>: View where Content: View {
    var content: () -> Content
    init(content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        ZStack {
            content()
        }
        .contentShape(Rectangle())
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ButtonView: View {
    let title: String
    let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 16)
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SquareView() {
                    Image("image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 16)
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
                }
            }
            Spacer()
        }
    }
}
