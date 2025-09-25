//
//  User.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let age: Int
    let profileImageName: String
    let bio: String
    let isOnline: Bool
    let lastSeen: Date
    
    static let sampleUsers = [
        User(name: "Amanda", age: 22, profileImageName: "stroll-1", bio: "What is your most favorite childhood memory?", isOnline: true, lastSeen: Date()),
        User(name: "Malte", age: 31, profileImageName: "stroll-2", bio: "What is the most important lesson you've learned?", isOnline: false, lastSeen: Date().addingTimeInterval(-3600)),
        User(name: "Jessica", age: 28, profileImageName: "stroll-3", bio: "They made a move!", isOnline: true, lastSeen: Date()),
        User(name: "Sila", age: 25, profileImageName: "stroll-4", bio: "You: I love the people there too, it's so nice", isOnline: false, lastSeen: Date().addingTimeInterval(-7200)),
        User(name: "Marie", age: 29, profileImageName: "stroll-2", bio: "Hahaha that's interesting, it does seem like people here are thriv...", isOnline: true, lastSeen: Date())
    ]
}
