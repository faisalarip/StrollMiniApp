//
//  AnimatedComponents.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import SwiftUI
import Combine

struct PulsingCircle: View {
    @State private var isPulsing = false
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -8
        }
    }
}

struct SwipeableCard: View {
    let user: User
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.8, blue: 0.6),
                        Color(red: 0.8, green: 0.4, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(radius: 10)
            
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("\(user.name), \(user.age)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(user.bio)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .frame(width: 160, height: 200)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                    rotation = Double(value.translation.width / 10)
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        if value.translation.width > 0 {
                            onSwipeRight()
                        } else {
                            onSwipeLeft()
                        }
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: value.translation.width > 0 ? 500 : -500, height: 0)
                            rotation = value.translation.width > 0 ? 30 : -30
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    let icon: String
    let color: Color
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .shadow(color: color.opacity(0.3), radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 2 : 4)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct ShimmerEffect: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.white.opacity(0.3),
                Color.clear
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .rotationEffect(.degrees(30))
        .offset(x: phase)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 300
            }
        }
    }
}

struct InteractiveButton: View {
    let title: String
    let action: () -> Void
    let isSelected: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? Color.white : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: 2)
                        )
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

struct WaveAnimation: View {
    @State private var waveOffset = Angle(degrees: 0)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height * 0.5
                let wavelength = width / 4
                
                path.move(to: CGPoint(x: 0, y: midHeight))
                
                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / wavelength
                    let sine = sin(relativeX + waveOffset.radians)
                    let y = midHeight + sine * 20
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue.opacity(0.6), lineWidth: 2)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = Angle(degrees: 360)
            }
        }
    }
}
