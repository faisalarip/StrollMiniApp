//
//  ContentView.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = StrollViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        HeaderView(viewModel: viewModel)
                        
                        if viewModel.isLoading {
                            LoadingView()
                        } else if let errorMessage = viewModel.errorMessage {
                            ErrorView(
                                message: errorMessage,
                                onRetry: {
                                    viewModel.errorMessage = nil
                                    viewModel.refreshUsers()
                                }
                            )
                        } else {
                            MainContentView(viewModel: viewModel)
                        }
                        
                        Spacer()
                        
//                        BottomTabBar(viewModel: viewModel, selectedTab: $selectedTab)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.connectionStatusPublisher) { status in
            if status == .disconnected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    viewModel.reconnectRealtime()
                }
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            InteractiveButton(
                title: "Try Again",
                action: onRetry,
                isSelected: false
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HeaderView: View {
    @ObservedObject var viewModel: StrollViewModel
    @State private var showTabBarDemo = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Your Turn section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Your Turn")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if viewModel.unreadMessagesCount > 0 {
                            Text("\(viewModel.unreadMessagesCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("Make your move, they are waiting ✨")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Profile avatar with online indicator
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("A")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    PulsingCircle(color: .green, size: 12)
                        .offset(x: 2, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}

struct ConnectionStatusView: View {
    let status: RealtimeService.ConnectionStatus
    
    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
    }
    
    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .connecting:
            return .yellow
        case .disconnected:
            return .red
        case .error:
            return .red
        }
    }
}

struct MainContentView: View {
    @ObservedObject var viewModel: StrollViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // User cards section
            UserCardsView(viewModel: viewModel)
            
            // Chat section
            ChatSectionView(viewModel: viewModel)
        }
        .padding(.horizontal, 20)
    }
}

struct UserCardsView: View {
    @ObservedObject var viewModel: StrollViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.filteredUsers.prefix(3)) { user in
                    UserCardView(user: user, viewModel: viewModel)
                }
            }
            .padding(20)
        }
    }
}

struct UserCardView: View {
    let user: User
    @ObservedObject var viewModel: StrollViewModel
    @State private var isPressed = false
    @State private var cardGradient: [Color] = []
    
    var body: some View {
        ZStack {
            // Background gradient with blur effect
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: cardGradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                        .overlay(content: {
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.75)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .cornerRadius(20, corners: .allCorners)
                        })
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
            
            VStack(spacing: 0) {
                // Notification badge
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text("They made a move!")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.6))
                    )
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                }
                
                Spacer()
                
                // Main content
                VStack(spacing: 8) {
                    Spacer()
                    
                    // "Tap to answer" text
                    Text("Tap to answer")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.5))
                    
                    Spacer()
                    
                    // User name and age
                    Text("\(user.name), \(user.age)")
                        .font(Font.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Question text
                    Text(user.bio.isEmpty ? "What is your most favorite childhood memory?" : user.bio)
                        .font(Font.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
        }
        .frame(width: 180, height: 260)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onAppear {
            generateRandomGradient()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
//        .gesture(
//            DragGesture()
//                .onEnded { value in
//                    if abs(value.translation.width) > 100 {
//                        if value.translation.width > 0 {
//                            viewModel.swipeUser(user, direction: .right)
//                        } else {
//                            viewModel.swipeUser(user, direction: .left)
//                        }
//                    }
//                }
//        )
    }
    
    private func generateRandomGradient() {
        let gradientSets: [[Color]] = [
            [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.2, green: 0.4, blue: 0.8)], // Green to Blue
            [Color(red: 0.8, green: 0.4, blue: 0.6), Color(red: 0.6, green: 0.2, blue: 0.8)], // Pink to Purple
            [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.8, green: 0.3, blue: 0.5)], // Orange to Pink
            [Color(red: 0.3, green: 0.6, blue: 0.9), Color(red: 0.6, green: 0.3, blue: 0.9)], // Blue to Purple
            [Color(red: 0.8, green: 0.5, blue: 0.3), Color(red: 0.5, green: 0.3, blue: 0.7)], // Brown to Purple
            [Color(red: 0.2, green: 0.7, blue: 0.8), Color(red: 0.7, green: 0.2, blue: 0.6)]  // Cyan to Magenta
        ]
        
        cardGradient = gradientSets.randomElement() ?? gradientSets[0]
    }
}

struct ChatSectionView: View {
    @ObservedObject var viewModel: StrollViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chat tabs
            HStack {
                ForEach(ChatTab.allCases, id: \.self) { tab in
                    Button(action: {
                        viewModel.selectedTab = tab
                    }) {
                        Text(tab.title)
                            .font(.headline)
                            .fontWeight(viewModel.selectedTab == tab ? .bold : .regular)
                            .foregroundColor(viewModel.selectedTab == tab ? .white : .gray)
                    }
                    
                    if tab != ChatTab.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Chat subtitle
            Text("The ice is broken. Time to hit it off")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
            
            // Chat list
            ChatListView(viewModel: viewModel)
        }
    }
}

struct ChatListView: View {
    @ObservedObject var viewModel: StrollViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredUsers) { user in
                ChatRowView(user: user) {
                    viewModel.selectUser(user)
                }
                
                // Add separator line between chat rows (except for the last one)
                if user.id != viewModel.filteredUsers.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 84) // Align with message content
                }
            }
        }
    }
}

struct ChatRowView: View {
    let user: User
    let onTap: () -> Void
    @State private var isTyping = false
    @State private var waveformHeights: [CGFloat] = []
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image with specific gradients for each user
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(profileGradient(for: user.name))
                        .frame(width: 56, height: 56)
                        .overlay(
                            profileImageContent(for: user.name)
                        )
                    
                    // Online status indicator (removed for this design)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(user.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Status badges
                        if user.name == "Jessica" {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.init(hex: .baseHexPurple))
                                    .frame(width: 6, height: 6)
                                Text("New chat")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.init(hex: .baseHexPurple))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.init(hex: .baseHexPurple).opacity(0.15))
                            .cornerRadius(12)
                        } else if user.name == "Amanda" || user.name == "Marie" {
                            Text("Your move")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text(timeString(for: user.name))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.init(hex: .baseHexPurple).opacity(0.6))
                    }
                    
                    HStack(spacing: 8) {
                        messageContent(for: user.name)
                        Spacer()
                        if user.name == "Jessica" {
                            Button(action: {}) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.init(hex: .baseHexPurple))
                                    .overlay(
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.black)
                                    )
                            }
                            .frame(width: 32, height: 20)
                        } else if user.name == "Marie" {
                            Circle()
                                .fill(Color.init(hex: .baseHexPurple))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("4")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                )
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if waveformHeights.isEmpty {
                waveformHeights = (0..<8).map { _ in CGFloat.random(in: 4...12) }
            }
        }
    }
    
    private func profileGradient(for name: String) -> LinearGradient {
        switch name {
        case "Jessica":
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.4), Color(red: 0.1, green: 0.5, blue: 0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Amanda":
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.8), Color(red: 0.6, green: 0.2, blue: 0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Sila":
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Marie":
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.3, green: 0.6, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    @ViewBuilder
    private func profileImageContent(for name: String) -> some View {
        // For now, using initials. In a real app, these would be actual profile images
        Text(String(name.prefix(1)))
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func messageContent(for name: String) -> some View {
        switch name {
        case "Jessica":
            HStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.init(hex: .baseHexPurple))
                
                // Voice waveform
                HStack(spacing: 2) {
                    ForEach(0..<8) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.init(hex: .baseHexPurple))
                            .frame(width: 2, height: waveformHeights.indices.contains(index) ? waveformHeights[index] : 8)
                    }
                }
                
                Text("00:58")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        case "Amanda":
            Text("Lol I love house music too")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
        case "Sila":
            Text("You: I love the people there tbh, have you been?")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        case "Marie":
            Text("Hahaha that's interesting, it does seem like people here are startin...")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
        default:
            Text("Last seen \(DateFormatter.relativeFormatter.string(from: user.lastSeen))")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func timeString(for name: String) -> String {
        switch name {
        case "Jessica", "Amanda", "Marie":
            return "6:21 pm"
        case "Sila":
            return "Wed"
        default:
            return DateFormatter.chatTimeFormatter.string(from: user.lastSeen)
        }
    }
}

struct BottomTabBar: View {
    @ObservedObject var viewModel: StrollViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            HStack {
                TabBarItem(icon: "message.fill", title: "Chats", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }
                TabBarItem(icon: "clock.fill", title: "Recents", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 1
                    }
                }
                TabBarItem(icon: "heart.fill", title: "Matches", isSelected: selectedTab == 2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 2
                    }
                }
                TabBarItem(icon: "person.fill", title: "Profile", isSelected: selectedTab == 3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 3
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.9))
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(
                        action: {
                            // Handle new chat action
                            print("New chat tapped")
                        }, icon: "plus",
                        color: Color.init(hex: .baseHexPurple)
                    )
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Loading...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension String {
    public static var baseHexPurple: String {
        return "#7d60db"
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    UserCardView(user: .sampleUsers.first!, viewModel: StrollViewModel())
}

