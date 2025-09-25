import SwiftUI

// MARK: - Tab Content Views

// MARK: - Home Tab View
struct HomeTabView: View {
    
    var body: some View {
        Text("Home Screen")
    }
}

// MARK: - Search Tab View
struct SearchTabView: View {
    var body: some View {
        Text("Search Screen")
    }
}

// MARK: - Messages Tab View
struct MessagesTabView: View {
    
    var body: some View {
        Text("Chat Screen")
    }
}

// MARK: - Profile Tab View
struct ProfileTabView: View {
    
    var body: some View {
        Text("Profile Screen")
    }
}

// MARK: - Extensions

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
