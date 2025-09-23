//
//  InteractiveSearchView.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import SwiftUI
import Combine

struct InteractiveSearchView: View {
    @ObservedObject var viewModel: StrollViewModel
    @State private var isSearchActive = false
    @State private var searchFieldOffset: CGFloat = 0
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            searchHeader
            
            // Search Results or Main Content
            if isSearchActive && !viewModel.searchText.isEmpty {
                searchResults
            } else {
                mainContent
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onTapGesture {
            if isSearchActive {
                dismissSearch()
            }
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            HStack {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.title3)
                    
                    TextField("Search users...", text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .foregroundColor(.white)
                        .onTapGesture {
                            activateSearch()
                        }
                        .onChange(of: viewModel.searchText) { _ in
                            if !viewModel.searchText.isEmpty && !isSearchActive {
                                activateSearch()
                            }
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            dismissSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isSearchActive ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
                .offset(x: searchFieldOffset)
                
                if isSearchActive {
                    Button("Cancel") {
                        dismissSearch()
                    }
                    .foregroundColor(.blue)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSearchActive)
            
            // Search Filters (when active)
            if isSearchActive {
                searchFilters
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top, 10)
        .background(Color.black)
    }
    
    private var searchFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "Online", isSelected: true) {
                    // Filter by online users
                }
                
                FilterChip(title: "Recent", isSelected: false) {
                    // Filter by recent activity
                }
                
                FilterChip(title: "Nearby", isSelected: false) {
                    // Filter by location
                }
                
                FilterChip(title: "New", isSelected: false) {
                    // Filter by new users
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredUsers) { user in
                    SearchResultRow(user: user) {
                        viewModel.selectUser(user)
                        dismissSearch()
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredUsers.count)
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Quick Actions
                quickActions
                
                // Featured Users
                featuredUsers
                
                // Recent Activity
                recentActivity
            }
            .padding(.top, 20)
        }
    }
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Discover",
                        subtitle: "Find new people",
                        color: .pink
                    ) {
                        // Handle discover action
                    }
                    
                    QuickActionCard(
                        icon: "message.fill",
                        title: "Chat",
                        subtitle: "Start conversation",
                        color: .blue
                    ) {
                        // Handle chat action
                    }
                    
                    QuickActionCard(
                        icon: "star.fill",
                        title: "Favorites",
                        subtitle: "Your liked profiles",
                        color: .yellow
                    ) {
                        // Handle favorites action
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var featuredUsers: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {
                    // Handle see all action
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.users.prefix(5)) { user in
                        FeaturedUserCard(user: user) {
                            viewModel.selectUser(user)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
//            VStack(spacing: 12) {
//                ForEach(viewModel.users.prefix(3)) { user in
//                    ActivityRow(user: user)
//                }
//            }
//            .padding(.horizontal, 20)
        }
    }
    
    private func activateSearch() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isSearchActive = true
            searchFieldOffset = 0
        }
        isSearchFocused = true
    }
    
    private func dismissSearch() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isSearchActive = false
            searchFieldOffset = 0
        }
        isSearchFocused = false
        viewModel.searchText = ""
    }
}

struct SearchResultRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    if user.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .offset(x: 22, y: 22)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(user.name), \(user.age)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 120, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct FeaturedUserCard: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.8),
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 120)
                    
                    VStack {
                        Spacer()
                        
                        if user.isOnline {
                            HStack {
                                Spacer()
                                PulsingCircle(color: .green, size: 8)
                                    .padding(.trailing, 8)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                }
                
                Text(user.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    InteractiveSearchView(viewModel: StrollViewModel())
}
