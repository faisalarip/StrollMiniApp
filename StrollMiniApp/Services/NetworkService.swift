//
//  NetworkService.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], NetworkError>
    func updateUserStatus(_ userId: UUID, isOnline: Bool) -> AnyPublisher<User, NetworkError>
    func sendMessage(_ message: String, to userId: UUID) -> AnyPublisher<ChatMessage, NetworkError>
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

class NetworkService: NetworkServiceProtocol {
    private let session = URLSession.shared
    private let baseURL = "https://api.strollapp.com/v1"
    
    func fetchUsers() -> AnyPublisher<[User], NetworkError> {
        // Simulate network request with Combine
        return Just(User.sampleUsers)
            .delay(for: .seconds(Double.random(in: 0.5...2.0)), scheduler: DispatchQueue.main)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func updateUserStatus(_ userId: UUID, isOnline: Bool) -> AnyPublisher<User, NetworkError> {
        // Simulate API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let user = User.sampleUsers.first(where: { $0.id == userId }) {
                    let updatedUser = User(
                        name: user.name,
                        age: user.age,
                        profileImageName: user.profileImageName,
                        bio: user.bio,
                        isOnline: isOnline,
                        lastSeen: isOnline ? Date() : user.lastSeen
                    )
                    promise(.success(updatedUser))
                } else {
                    promise(.failure(.noData))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendMessage(_ message: String, to userId: UUID) -> AnyPublisher<ChatMessage, NetworkError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let chatMessage = ChatMessage(
                    text: message,
                    timestamp: Date(),
                    isFromCurrentUser: true,
                    senderName: "You"
                )
                promise(.success(chatMessage))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Real-time Updates Service
class RealtimeService: ObservableObject {
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var incomingMessages: [ChatMessage] = []
    @Published var userStatusUpdates: [UUID: Bool] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var messageTimer: Timer?
    private var statusTimer: Timer?
    
    enum ConnectionStatus {
        case connected
        case connecting
        case disconnected
        case error
    }
    
    init() {
        setupRealtimeConnection()
    }
    
    deinit {
        disconnect()
    }
    
    private func setupRealtimeConnection() {
        // Simulate WebSocket connection
        connectionStatus = .connecting
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.connectionStatus = .connected
            self?.startMessageSimulation()
            self?.startStatusUpdates()
        }
    }
    
    private func startMessageSimulation() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.simulateIncomingMessage()
        }
    }
    
    private func startStatusUpdates() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.simulateStatusUpdate()
        }
    }
    
    private func simulateIncomingMessage() {
        let messages = [
            "Hey! How's it going?",
            "Want to grab coffee later?",
            "That sounds amazing!",
            "I'm free this weekend",
            "Let's plan something fun!"
        ]
        
        let randomMessage = messages.randomElement() ?? "Hello!"
        let message = ChatMessage(
            text: randomMessage,
            timestamp: Date(),
            isFromCurrentUser: false,
            senderName: User.sampleUsers.randomElement()?.name ?? "Someone"
        )
        
        incomingMessages.append(message)
    }
    
    private func simulateStatusUpdate() {
        if let randomUser = User.sampleUsers.randomElement() {
            userStatusUpdates[randomUser.id] = Bool.random()
        }
    }
    
    func disconnect() {
        messageTimer?.invalidate()
        statusTimer?.invalidate()
        connectionStatus = .disconnected
    }
    
    func reconnect() {
        disconnect()
        setupRealtimeConnection()
    }
}

// MARK: - Analytics Service
class AnalyticsService: ObservableObject {
    @Published var userInteractions: [UserInteraction] = []
    @Published var sessionMetrics: SessionMetrics = SessionMetrics()
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    
    struct UserInteraction {
        let id = UUID()
        let type: InteractionType
        let userId: UUID?
        let timestamp: Date
        
        enum InteractionType {
            case profileView
            case messagesSent
            case swipeLeft
            case swipeRight
            case search
        }
    }
    
    struct SessionMetrics {
        var sessionStart: Date = Date()
        var profileViews: Int = 0
        var messagesSent: Int = 0
        var searchQueries: Int = 0
        var timeSpent: TimeInterval = 0
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        setupAnalytics()
    }
    
    private func setupAnalytics() {
        // Track session time
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSessionTime()
        }
        .store(in: &cancellables)
    }
    
    func trackInteraction(_ type: UserInteraction.InteractionType, userId: UUID? = nil) {
        let interaction = UserInteraction(
            type: type,
            userId: userId,
            timestamp: Date()
        )
        
        userInteractions.append(interaction)
        updateMetrics(for: type)
    }
    
    private func updateMetrics(for type: UserInteraction.InteractionType) {
        switch type {
        case .profileView:
            sessionMetrics.profileViews += 1
        case .messagesSent:
            sessionMetrics.messagesSent += 1
        case .search:
            sessionMetrics.searchQueries += 1
        default:
            break
        }
    }
    
    private func updateSessionTime() {
        sessionMetrics.timeSpent = Date().timeIntervalSince(sessionMetrics.sessionStart)
    }
}

// MARK: - Timer Extension for Combine
extension Timer {
    func store(in set: inout Set<AnyCancellable>) {
        // Convert Timer to AnyCancellable for proper memory management
        let cancellable = AnyCancellable {
            self.invalidate()
        }
        set.insert(cancellable)
    }
}