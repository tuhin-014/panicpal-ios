import SwiftUI

struct CompanionView: View {
    let message: String
    @State private var scale: CGFloat = 1.0
    @State private var eyesClosed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Pal mascot
            ZStack {
                Circle()
                    .fill(AppColors.deepTeal)
                    .frame(width: 44, height: 44)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            scale = 1.05
                        }
                        startBlinking()
                    }
                
                // Eyes and smile
                VStack(spacing: 2) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.white)
                            .frame(width: eyesClosed ? 6 : 5, height: eyesClosed ? 1 : 5)
                        Circle()
                            .fill(.white)
                            .frame(width: eyesClosed ? 6 : 5, height: eyesClosed ? 1 : 5)
                    }
                    
                    // Smile
                    Arc()
                        .stroke(.white, lineWidth: 1.5)
                        .frame(width: 12, height: 6)
                }
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.deepTeal.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.15)) { eyesClosed = true }
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.easeInOut(duration: 0.15)) { eyesClosed = false }
            }
        }
    }
}

struct Arc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY),
            radius: rect.width / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        return path
    }
}
