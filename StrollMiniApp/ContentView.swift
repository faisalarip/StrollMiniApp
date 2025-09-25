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
                                .background(Color.init(hex: .baseHexPurple))
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
//                    Circle()
//                        .fill(LinearGradient(
//                            gradient: Gradient(colors: [Color.orange, Color.pink]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ))
//                        .frame(width: 50, height: 50)
//                        .overlay(
//                            Text("A")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                        )
//                    
//                    PulsingCircle(color: .green, size: 12)
//                        .offset(x: 2, y: 2)
                    CircularProgressImageView()
                        .frame(width: 56, height: 56)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
                        VStack {
                            Text(tab.title)
                                .font(Font.system(size: 24, weight: .bold))
                                .fontWeight(viewModel.selectedTab == tab ? .bold : .regular)
                                .foregroundColor(viewModel.selectedTab == tab ? .white : .gray)
                            
                            if viewModel.selectedTab == tab {
                                Rectangle()
                                    .frame(width: 120, height: 2)
                                    .foregroundStyle(Color.white)
                            } else {
                                Rectangle()
                                    .frame(width: 120, height: 2)
                                    .foregroundStyle(Color.clear)
                            }
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 20)
            
            // Chat subtitle
            Text("The ice is broken. Time to hit it off")
                .font(Font.system(size: 12, weight: .light, design: .serif))
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

