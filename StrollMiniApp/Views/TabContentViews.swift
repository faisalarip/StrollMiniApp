import SwiftUI

// MARK: - Tab Content Views

// MARK: - Home Tab View
struct HomeTabView: View {
    @State private var showingDetail = false
    @State private var selectedUser: User?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome Back!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Discover new connections")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(title: "Matches", value: "24", color: .blue)
                        StatCard(title: "Messages", value: "12", color: .green)
                        StatCard(title: "Views", value: "156", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(0..<5) { index in
                            ActivityRow(
                                title: "New match with Sarah",
                                subtitle: "2 hours ago",
                                icon: "heart.fill",
                                color: .pink
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingDetail = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            SettingsView()
        }
    }
}

// MARK: - Search Tab View
struct SearchTabView: View {
    @State private var searchText = ""
    @State private var selectedFilter = 0
    @State private var showingFilters = false
    
    let filters = ["All", "Online", "Nearby", "New"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search users...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<filters.count, id: \.self) { index in
                                FilterChip(
                                    title: filters[index],
                                    isSelected: selectedFilter == index
                                ) {
                                    selectedFilter = index
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Search Results
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(0..<10) { index in
                            SearchResultCard(
                                name: "User \(index + 1)",
                                age: 20 + index,
                                distance: "\(index + 1) km away",
                                imageColor: Color.random
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView()
        }
    }
}

// MARK: - Messages Tab View
struct MessagesTabView: View {
    @State private var selectedConversation: ChatMessage?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<15) { index in
                    ConversationRow(
                        name: "Contact \(index + 1)",
                        lastMessage: "Hey! How are you doing?",
                        timestamp: "2:30 PM",
                        isUnread: index < 3,
                        isOnline: index % 3 == 0
                    )
                    .onTapGesture {
                        // Handle conversation selection
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}

// MARK: - Profile Tab View
struct ProfileTabView: View {
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("JD")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("John Doe")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Software Developer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                    // Profile Stats
                    HStack(spacing: 32) {
                        ProfileStat(title: "Matches", value: "24")
                        ProfileStat(title: "Likes", value: "156")
                        ProfileStat(title: "Views", value: "1.2K")
                    }
                    
                    // Profile Sections
                    VStack(spacing: 16) {
                        ProfileSection(title: "About", content: "Love traveling and meeting new people. Always up for an adventure!")
                        ProfileSection(title: "Interests", content: "Photography, Hiking, Cooking, Music")
                        ProfileSection(title: "Location", content: "San Francisco, CA")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        // Handle settings
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct SearchResultCard: View {
    let name: String
    let age: Int
    let distance: String
    let imageColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(imageColor.gradient)
                .frame(height: 120)
                .cornerRadius(12)
                .overlay(
                    Text(String(name.prefix(2)))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 2) {
                Text("\(name), \(age)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(distance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ConversationRow: View {
    let name: String
    let lastMessage: String
    let timestamp: String
    let isUnread: Bool
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 50, height: 50)
                
                Text(String(name.prefix(2)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 18, y: 18)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .fontWeight(isUnread ? .semibold : .regular)
                    
                    Spacer()
                    
                    Text(timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(isUnread ? .primary : .secondary)
                    .lineLimit(1)
            }
            
            if isUnread {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProfileStat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Modal Views

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Preferences") {
                    Label("Notifications", systemImage: "bell")
                    Label("Privacy", systemImage: "lock")
                    Label("Account", systemImage: "person.circle")
                }
                
                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("Contact Us", systemImage: "envelope")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Distance") {
                    Label("Within 5 km", systemImage: "location")
                    Label("Within 10 km", systemImage: "location")
                    Label("Within 25 km", systemImage: "location")
                }
                
                Section("Age Range") {
                    Label("18-25", systemImage: "person")
                    Label("26-35", systemImage: "person")
                    Label("36+", systemImage: "person")
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: .constant("John Doe"))
                    TextField("Bio", text: .constant("Love traveling..."), axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Photos") {
                    Button("Add Photo") {
                        // Handle photo addition
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
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