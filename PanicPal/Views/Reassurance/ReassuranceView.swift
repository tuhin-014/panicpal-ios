import SwiftUI
import SwiftData

struct ReassuranceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteReassurance]
    @State private var currentIndex = 0
    @State private var showFavoritesOnly = false
    
    private let gradients: [Color] = [
        AppColors.deepTeal,
        AppColors.softLavender,
        Color.blue.opacity(0.3)
    ]
    
    private var displayMessages: [(index: Int, text: String)] {
        if showFavoritesOnly {
            let favIndices = Set(favorites.map(\.messageIndex))
            return ReassuranceMessages.all.enumerated()
                .filter { favIndices.contains($0.offset) }
                .map { (index: $0.offset, text: $0.element) }
        }
        return ReassuranceMessages.all.enumerated().map { (index: $0.offset, text: $0.element) }
    }
    
    private func isFavorited(_ index: Int) -> Bool {
        favorites.contains { $0.messageIndex == index }
    }
    
    var body: some View {
        ZStack {
            gradients[currentIndex % gradients.count].opacity(0.2)
                .ignoresSafeArea()
                .animation(.easeInOut, value: currentIndex)
            
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        showFavoritesOnly.toggle()
                        currentIndex = 0
                    } label: {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(showFavoritesOnly ? .red : .secondary)
                    }
                }
                .padding()
                
                if displayMessages.isEmpty {
                    Spacer()
                    Text("No favorites yet.\nTap ❤️ on a card to save it.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(displayMessages.enumerated()), id: \.offset) { idx, item in
                            VStack(spacing: 30) {
                                Spacer()
                                Text(item.text)
                                    .font(.system(size: 28, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(AppColors.deepTeal)
                                    .padding(.horizontal, 30)
                                
                                Button {
                                    toggleFavorite(item.index)
                                } label: {
                                    Image(systemName: isFavorited(item.index) ? "heart.fill" : "heart")
                                        .font(.title)
                                        .foregroundStyle(isFavorited(item.index) ? .red : .secondary)
                                }
                                Spacer()
                            }
                            .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
            }
        }
    }
    
    private func toggleFavorite(_ messageIndex: Int) {
        if let existing = favorites.first(where: { $0.messageIndex == messageIndex }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteReassurance(messageIndex: messageIndex))
        }
        try? modelContext.save()
    }
}
