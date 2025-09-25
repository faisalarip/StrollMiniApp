//
//  CircularProgressImageView.swift
//  StrollMiniApp
//
//  Created by faisal nur arif on 25/09/25.
//


import SwiftUI

struct CircularProgressImageView: View {
    var progress: CGFloat = 0.9 // 90%
    var score: Int = 90
    var image: Image = Image("stroll-3")
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.2)
                .foregroundColor(.gray)
            
            // Progress Circle with Gradient
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green, .green, .black.opacity(0.8)]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
            
            // Profile Image
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.clear, lineWidth: 2))
//                .padding(15)
            
            // Score Number
            VStack {
                Spacer()
                Text("\(score)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.bottom, -30)
        }
        .frame(width: 56, height: 56)
    }
}

struct CircularProgressImageView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressImageView()
    }
}
