//
//  TabBarDemo.swift
//  StrollMiniApp
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct TabBarDemo: View {
    @State private var selectedTab = 0
    @State private var badgeCount = 3
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SwiftUI TabBarController Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("This demonstrates a UITabBarController equivalent built with SwiftUI")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Basic TabBarController Demo
                VStack(alignment: .leading, spacing: 10) {
                    Text("Basic TabBarController")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TabBarController(
                        tabs: [
                            TabItem(title: "Home", icon: "house", selectedIcon: "house.fill") {
                                TabContentView(tabIndex: 0, tabName: "Home")
                            },
                            TabItem(title: "Search", icon: "magnifyingglass", selectedIcon: "magnifyingglass") {
                                TabContentView(tabIndex: 1, tabName: "Search")
                            },
                            TabItem(title: "Messages", icon: "message", selectedIcon: "message.fill", badgeCount: badgeCount) {
                                TabContentView(tabIndex: 2, tabName: "Messages")
                            },
                            TabItem(title: "Profile", icon: "person", selectedIcon: "person.fill") {
                                TabContentView(tabIndex: 3, tabName: "Profile")
                            }
                        ]
                    )
                    .frame(height: 300)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
                
                // Advanced TabBarController Demo
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Advanced TabBarController")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    AdvancedTabBarController()
//                        .frame(height: 300)
//                        .background(Color(.systemBackground))
//                        .cornerRadius(12)
//                        .shadow(radius: 5)
//                        .padding(.horizontal)
//                }
                
                // Controls
                VStack(spacing: 15) {
                    HStack {
                        Text("Badge Count:")
                        Stepper(value: $badgeCount, in: 0...10) {
                            Text("\(badgeCount)")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button("Reset Badge") {
                        badgeCount = 0
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func getTabName(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Search"
        case 2: return "Messages"
        case 3: return "Profile"
        default: return "Tab \(index)"
        }
    }
}

struct TabContentView: View {
    let tabIndex: Int
    let tabName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: getIconName())
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(tabName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tab \(tabIndex)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("This is the content for the \(tabName) tab. You can add any SwiftUI views here.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func getIconName() -> String {
        switch tabIndex {
        case 0: return "house.fill"
        case 1: return "magnifyingglass"
        case 2: return "message.fill"
        case 3: return "person.fill"
        default: return "circle.fill"
        }
    }
}

#Preview {
    TabBarDemo()
}