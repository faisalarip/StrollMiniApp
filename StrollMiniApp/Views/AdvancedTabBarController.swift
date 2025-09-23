import SwiftUI
import Combine

// MARK: - Advanced Tab Bar Controller with Enhanced Features

// MARK: - Tab Navigation Coordinator
class TabNavigationCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var tabBadges: [Int: Int] = [:]
    @Published var isTabBarHidden: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    /// Programmatically switch to a specific tab
    func switchToTab(_ index: Int, animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
            }
        } else {
            selectedTab = index
        }
    }
    
    /// Update badge count for a specific tab
    func updateBadge(for tabIndex: Int, count: Int?) {
        if let count = count, count > 0 {
            tabBadges[tabIndex] = count
        } else {
            tabBadges.removeValue(forKey: tabIndex)
        }
    }
    
    /// Hide or show the tab bar
    func setTabBarHidden(_ hidden: Bool, animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                isTabBarHidden = hidden
            }
        } else {
            isTabBarHidden = hidden
        }
    }
    
    /// Handle deep link navigation
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate to appropriate tab
        let path = url.path
        switch path {
        case "/home":
            switchToTab(0)
        case "/search":
            switchToTab(1)
        case "/messages":
            switchToTab(2)
        case "/profile":
            switchToTab(3)
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        // Listen for badge updates from other parts of the app
        NotificationCenter.default.publisher(for: .tabBadgeUpdate)
            .sink { [weak self] notification in
                if let userInfo = notification.userInfo,
                   let tabIndex = userInfo["tabIndex"] as? Int,
                   let count = userInfo["count"] as? Int {
                    self?.updateBadge(for: tabIndex, count: count)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Enhanced Tab Item
struct EnhancedTabItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let selectedIcon: String?
    let view: AnyView
    let isEnabled: Bool
    let accessibilityLabel: String?
    
    init<V: View>(
        title: String,
        icon: String,
        selectedIcon: String? = nil,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        @ViewBuilder view: () -> V
    ) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.view = AnyView(view())
    }
    
    static func == (lhs: EnhancedTabItem, rhs: EnhancedTabItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Advanced Tab Bar Appearance
struct AdvancedTabBarAppearance {
    var backgroundColor: Color = Color(.systemBackground)
    var selectedColor: Color = .blue
    var unselectedColor: Color = .gray
    var disabledColor: Color = Color.gray.opacity(0.3)
    var badgeColor: Color = .red
    var shadowColor: Color = Color.black.opacity(0.1)
    var cornerRadius: CGFloat = 0
    var height: CGFloat = 83
    var itemSpacing: CGFloat = 0
    var animationDuration: Double = 0.3
    var showShadow: Bool = true
    var blurEffect: Bool = false
    var hapticFeedback: Bool = true
    var customFont: Font? = nil
    var iconSize: CGFloat = 24
    var titleSize: CGFloat = 10
}

// MARK: - Advanced Tab Bar Controller
struct AdvancedTabBarController: View {
    @StateObject private var coordinator = TabNavigationCoordinator()
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    let tabs: [EnhancedTabItem]
    let appearance: AdvancedTabBarAppearance
    let onTabChange: ((Int) -> Void)?
    
    init(
        tabs: [EnhancedTabItem],
        appearance: AdvancedTabBarAppearance = AdvancedTabBarAppearance(),
        onTabChange: ((Int) -> Void)? = nil
    ) {
        self.tabs = tabs
        self.appearance = appearance
        self.onTabChange = onTabChange
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Content Area
                TabView(selection: $coordinator.selectedTab) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        tabs[index].view
                            .tag(index)
                            .environmentObject(coordinator)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: appearance.animationDuration), value: coordinator.selectedTab)
                
                // Custom Tab Bar
                VStack {
                    Spacer()
                    
                    if !coordinator.isTabBarHidden {
                        AdvancedCustomTabBar(
                            tabs: tabs,
                            coordinator: coordinator,
                            appearance: appearance,
                            geometry: geometry
                        )
                        .offset(y: dragOffset)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onChange(of: coordinator.selectedTab) { newValue in
            onTabChange?(newValue)
            
            if appearance.hapticFeedback {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Handle app becoming active
        }
    }
}

// MARK: - Advanced Custom Tab Bar
struct AdvancedCustomTabBar: View {
    let tabs: [EnhancedTabItem]
    @ObservedObject var coordinator: TabNavigationCoordinator
    let appearance: AdvancedTabBarAppearance
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: appearance.itemSpacing) {
            ForEach(0..<tabs.count, id: \.self) { index in
                AdvancedTabBarItemView(
                    tab: tabs[index],
                    isSelected: coordinator.selectedTab == index,
                    badgeCount: coordinator.tabBadges[index],
                    appearance: appearance
                ) {
                    coordinator.switchToTab(index)
                }
                .frame(maxWidth: .infinity)
                .disabled(!tabs[index].isEnabled)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 8)
        .frame(height: appearance.height)
        .background(
            Group {
                if appearance.blurEffect {
                    BlurView(style: .systemMaterial)
                        .cornerRadius(appearance.cornerRadius, corners: [.topLeft, .topRight])
                } else {
                    appearance.backgroundColor
                        .cornerRadius(appearance.cornerRadius, corners: [.topLeft, .topRight])
                }
            }
            .shadow(
                color: appearance.showShadow ? appearance.shadowColor : .clear,
                radius: 8,
                x: 0,
                y: -2
            )
        )
    }
}

// MARK: - Advanced Tab Bar Item View
struct AdvancedTabBarItemView: View {
    let tab: EnhancedTabItem
    let isSelected: Bool
    let badgeCount: Int?
    let appearance: AdvancedTabBarAppearance
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background indicator for selected state
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(appearance.selectedColor.opacity(0.1))
                            .frame(width: 64, height: 32)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    }
                    
                    // Icon
                    Image(systemName: isSelected ? (tab.selectedIcon ?? tab.icon) : tab.icon)
                        .font(.system(size: appearance.iconSize, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(
                            tab.isEnabled
                                ? (isSelected ? appearance.selectedColor : appearance.unselectedColor)
                                : appearance.disabledColor
                        )
                        .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.1 : 1.0))
                        .offset(y: animationOffset)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                    
                    // Badge
                    if let badgeCount = badgeCount, badgeCount > 0 {
                        VStack {
                            HStack {
                                Spacer()
                                EnhancedBadgeView(count: badgeCount, color: appearance.badgeColor)
                                    .offset(x: 8, y: -8)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 32)
                
                // Title
                Text(tab.title)
                    .font(appearance.customFont ?? .system(size: appearance.titleSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(
                        tab.isEnabled
                            ? (isSelected ? appearance.selectedColor : appearance.unselectedColor)
                            : appearance.disabledColor
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .animation(.easeInOut(duration: appearance.animationDuration), value: isSelected)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(tab.accessibilityLabel ?? tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            if isSelected {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    animationOffset = -2
                }
            }
        }
        .onChange(of: isSelected) { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animationOffset = newValue ? -2 : 0
            }
        }
    }
}

// MARK: - Enhanced Badge View
struct EnhancedBadgeView: View {
    let count: Int
    let color: Color
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: count > 99 ? 24 : 18, height: 18)
                .scaleEffect(scale)
            
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Blur View for iOS
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Tab Bar Modifier
struct TabBarModifier: ViewModifier {
    @EnvironmentObject var coordinator: TabNavigationCoordinator
    let hidden: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                coordinator.setTabBarHidden(hidden)
            }
    }
}

extension View {
    func tabBarHidden(_ hidden: Bool = true) -> some View {
        modifier(TabBarModifier(hidden: hidden))
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let tabBadgeUpdate = Notification.Name("tabBadgeUpdate")
}

// MARK: - Demo Implementation
struct AdvancedTabBarDemo: View {
    var body: some View {
        AdvancedTabBarController(
            tabs: [
                EnhancedTabItem(
                    title: "Home",
                    icon: "house",
                    selectedIcon: "house.fill",
                    accessibilityLabel: "Home Tab"
                ) {
                    HomeTabView()
                },
                EnhancedTabItem(
                    title: "Search",
                    icon: "magnifyingglass",
                    accessibilityLabel: "Search Tab"
                ) {
                    SearchTabView()
                },
                EnhancedTabItem(
                    title: "Messages",
                    icon: "message",
                    selectedIcon: "message.fill",
                    accessibilityLabel: "Messages Tab"
                ) {
                    MessagesTabView()
                },
                EnhancedTabItem(
                    title: "Profile",
                    icon: "person",
                    selectedIcon: "person.fill",
                    accessibilityLabel: "Profile Tab"
                ) {
                    ProfileTabView()
                }
            ],
            appearance: AdvancedTabBarAppearance(
                selectedColor: .blue,
                blurEffect: true,
                hapticFeedback: true,
                iconSize: 22,
                titleSize: 10
            )
        ) { tabIndex in
            print("Switched to tab: \(tabIndex)")
        }
    }
}

// MARK: - Preview
struct AdvancedTabBarController_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTabBarDemo()
    }
}