//
//  UserCardView.swift
//  StrollMiniApp
//
//  Created by faisal nur arif on 25/09/25.
//
import SwiftUI

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
