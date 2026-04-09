import SwiftUI

struct LoadingIndicator: View {
    @State private var phase: Int = 0

    private let dotCount = 3
    private let animationDuration = 0.4

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { i in
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundStyle(.secondary)
                    .scaleEffect(phase == i ? 1.3 : 0.8)
                    .animation(
                        .easeInOut(duration: animationDuration)
                            .repeatForever()
                            .delay(Double(i) * animationDuration / Double(dotCount)),
                        value: phase
                    )
            }
        }
        .onAppear {
            phase = 1
        }
    }
}
