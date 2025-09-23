//
//  StrollViewModel.swift
//  StrollMiniApp
//
//  Created by faisalarip on 9/23/25.
//

import Foundation
import Combine
import SwiftUI

class StrollViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var currentUser: User?
    @Published var selectedTab: ChatTab = .chats
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var filteredUsers: [User] = []
    @Published var onlineUsersCount: Int = 0
    @Published var currentTime: Date = Date()
    @Published var connectionStatus: RealtimeService.ConnectionStatus = .disconnected
    @Published var unreadMessagesCount: Int = 0
    @Published var isRefreshing: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private let realtimeService: RealtimeService
    private let analyticsService: AnalyticsService
    private var timer: Timer?
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        self.realtimeService = RealtimeService()
        self.analyticsService = AnalyticsService(networkService: networkService)
        
        setupBindings()
        setupRealtimeBindings()
        loadUsers()
        startTimeUpdates()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Filter users based on search text with debouncing
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] searchText in
                guard let self = self else { return [] }
                
                // Track search analytics
                if !searchText.isEmpty {
                    self.analyticsService.trackInteraction(.search)
                }
                
                if searchText.isEmpty {
                    return self.users
                } else {
                    return self.users.filter { user in
                        user.name.localizedCaseInsensitiveContains(searchText) ||
                        user.bio.localizedCaseInsensitiveContains(searchText)
                    }
                }
            }
            .assign(to: \.filteredUsers, on: self)
            .store(in: &cancellables)
        
        // Count online users reactively
        $users
            .map { users in
                users.filter { $0.isOnline }.count
            }
            .assign(to: \.onlineUsersCount, on: self)
            .store(in: &cancellables)
        
        // Handle loading state changes
        $isLoading
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
        
        // Combine loading and refreshing states
        Publishers.CombineLatest($isLoading, $isRefreshing)
            .map { isLoading, isRefreshing in
                isLoading || isRefreshing
            }
            .sink { [weak self] isAnyLoading in
                // Handle combined loading state if needed
            }
            .store(in: &cancellables)
        
        // Auto-refresh users every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshUsersInBackground()
            }
            .store(in: &cancellables)
    }
    
    private func setupRealtimeBindings() {
        // Bind realtime service connection status
        realtimeService.$connectionStatus
            .assign(to: \.connectionStatus, on: self)
            .store(in: &cancellables)
        
        // Handle incoming messages
        realtimeService.$incomingMessages
            .sink { [weak self] messages in
                self?.unreadMessagesCount = messages.count
            }
            .store(in: &cancellables)
        
        // Handle user status updates
        realtimeService.$userStatusUpdates
            .sink { [weak self] statusUpdates in
                self?.handleUserStatusUpdates(statusUpdates)
            }
            .store(in: &cancellables)
    }
    
    private func loadUsers() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                    self?.currentUser = users.first
                    self?.filteredUsers = users
                }
            )
            .store(in: &cancellables)
    }
    
    private func refreshUsersInBackground() {
        guard !isLoading else { return }
        
        isRefreshing = true
        
        networkService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isRefreshing = false
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleUserStatusUpdates(_ updates: [UUID: Bool]) {
        for (userId, isOnline) in updates {
            if let index = users.firstIndex(where: { $0.id == userId }) {
                users[index] = User(
                    name: users[index].name,
                    age: users[index].age,
                    profileImageName: users[index].profileImageName,
                    bio: users[index].bio,
                    isOnline: isOnline,
                    lastSeen: isOnline ? Date() : users[index].lastSeen
                )
            }
        }
    }
    
    private func startTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }
    
    // MARK: - Public Methods
    func refreshUsers() {
        loadUsers()
    }
    
    func selectUser(_ user: User) {
        currentUser = user
        analyticsService.trackInteraction(.profileView, userId: user.id)
    }
    
    func toggleUserOnlineStatus(_ user: User) {
        networkService.updateUserStatus(user.id, isOnline: !user.isOnline)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedUser in
                    if let index = self?.users.firstIndex(where: { $0.id == updatedUser.id }) {
                        self?.users[index] = updatedUser
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func sendMessage(_ message: String, to user: User) {
        networkService.sendMessage(message, to: user.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] chatMessage in
                    self?.analyticsService.trackInteraction(.messagesSent, userId: user.id)
                    // Handle successful message sending
                }
            )
            .store(in: &cancellables)
    }
    
    func swipeUser(_ user: User, direction: SwipeDirection) {
        let interactionType: AnalyticsService.UserInteraction.InteractionType = 
            direction == .left ? .swipeLeft : .swipeRight
        
        analyticsService.trackInteraction(interactionType, userId: user.id)
        
        // Remove user from current list after swipe
        users.removeAll { $0.id == user.id }
    }
    
    func reconnectRealtime() {
        realtimeService.reconnect()
    }
    
    func clearUnreadMessages() {
        unreadMessagesCount = 0
    }
    
    // MARK: - Reactive Publishers
    var userUpdatesPublisher: AnyPublisher<[User], Never> {
        $users.eraseToAnyPublisher()
    }
    
    var searchResultsPublisher: AnyPublisher<[User], Never> {
        $filteredUsers.eraseToAnyPublisher()
    }
    
    var connectionStatusPublisher: AnyPublisher<RealtimeService.ConnectionStatus, Never> {
        $connectionStatus.eraseToAnyPublisher()
    }
}

enum SwipeDirection {
    case left, right
}

// MARK: - User Service
class UserService {
    func fetchUsers() -> AnyPublisher<[User], Error> {
        // Simulate API call
        return Just(User.sampleUsers)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
