//
//  ChatViewTab.swift
//  StrollMiniApp
//
//  Created by faisal nur arif on 25/09/25.
//

import SwiftUI

struct ChatViewTab: View {
    @StateObject private var viewModel = StrollViewModel()
    
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
                    }
                }
                .safeAreaPadding(.bottom)
                .padding(.bottom)
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

#Preview {
    ChatViewTab()
}
