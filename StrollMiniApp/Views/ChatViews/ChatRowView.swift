//
//  ChatRowView.swift
//  StrollMiniApp
//
//  Created by faisal nur arif on 25/09/25.
//
import SwiftUI

internal struct ChatRowView: View {
    let user: User
    let onTap: () -> Void
    @State private var isTyping = false
    @State private var waveformHeights: [CGFloat] = []
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image with specific gradients for each user
                ZStack(alignment: .bottomTrailing) {
//                    Circle()
//                        .fill(profileGradient(for: user.name))
//                        .frame(width: 56, height: 56)
//                        .overlay(
//                            profileImageContent(for: user.name)
//                        )
                    
                    Image(user.profileImageName)
                        .resizable()
                        .cornerRadius(28, corners: .allCorners)
                        .frame(width: 56, height: 56)
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

#Preview {
    ChatRowView(
        user: .sampleUsers.first!,
        onTap: {}
    )
}
