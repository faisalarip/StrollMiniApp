//
//  ChatMessage.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let timestamp: Date
    let isFromCurrentUser: Bool
    let senderName: String
    
    static let sampleMessages = [
        ChatMessage(text: "Hey! How's your day going?", timestamp: Date().addingTimeInterval(-3600), isFromCurrentUser: false, senderName: "Jessica"),
        ChatMessage(text: "Pretty good! Just finished work. How about you?", timestamp: Date().addingTimeInterval(-3500), isFromCurrentUser: true, senderName: "You"),
        ChatMessage(text: "Same here! Want to grab coffee later?", timestamp: Date().addingTimeInterval(-3400), isFromCurrentUser: false, senderName: "Jessica"),
        ChatMessage(text: "Sounds perfect! See you at 5?", timestamp: Date().addingTimeInterval(-3300), isFromCurrentUser: true, senderName: "You")
    ]
}

enum ChatTab: String, CaseIterable {
    case chats = "Chats"
    case pending = "Pending"
    
    var title: String {
        return self.rawValue
    }
}