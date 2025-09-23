import SwiftUI

// MARK: - Tab Item Model
struct TabItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let selectedIcon: String?
    let badgeCount: Int?
    let view: AnyView
    
    init<V: View>(title: String, icon: String, selectedIcon: String? = nil, badgeCount: Int? = nil, @ViewBuilder view: () -> V) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.badgeCount = badgeCount
        self.view = AnyView(view())
    }
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Tab Bar Appearance
struct TabBarAppearance {
    var backgroundColor: Color = Color(.systemBackground)
    var selectedColor: Color = .blue
    var unselectedColor: Color = .gray
    var badgeColor: Color = .red
    var shadowColor: Color = Color.black.opacity(0.1)
    var cornerRadius: CGFloat = 0
    var height: CGFloat = 83
    var itemSpacing: CGFloat = 0
    var animationDuration: Double = 0.3
    var showShadow: Bool = true
}

// MARK: - Custom Tab Bar Controller
struct TabBarController: View {
    @State private var selectedTab: Int = 0
    let tabs: [TabItem]
    let appearance: TabBarAppearance
    
    init(tabs: [TabItem], appearance: TabBarAppearance = TabBarAppearance()) {
        self.tabs = tabs
        self.appearance = appearance
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Content Area
                ZStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        tabs[index].view
                            .opacity(selectedTab == index ? 1 : 0)
                            .animation(.easeInOut(duration: appearance.animationDuration), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar
                CustomTabBar(
                    tabs: tabs,
                    selectedTab: $selectedTab,
                    appearance: appearance,
                    geometry: geometry
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Custom Tab Bar View
struct CustomTabBar: View {
    let tabs: [TabItem]
    @Binding var selectedTab: Int
    let appearance: TabBarAppearance
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: appearance.itemSpacing) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItemView(
                    tab: tabs[index],
                    isSelected: selectedTab == index,
                    appearance: appearance
                ) {
                    withAnimation(.easeInOut(duration: appearance.animationDuration)) {
                        selectedTab = index
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 8)
        .frame(height: appearance.height)
        .background(
            appearance.backgroundColor
                .cornerRadius(appearance.cornerRadius, corners: [.topLeft, .topRight])
                .shadow(
                    color: appearance.showShadow ? appearance.shadowColor : .clear,
                    radius: 8,
                    x: 0,
                    y: -2
                )
        )
    }
}

// MARK: - Tab Bar Item View
struct TabBarItemView: View {
    let tab: TabItem
    let isSelected: Bool
    let appearance: TabBarAppearance
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Icon
                    Image(systemName: isSelected ? (tab.selectedIcon ?? tab.icon) : tab.icon)
                        .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? appearance.selectedColor : appearance.unselectedColor)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                    
                    // Badge
                    if let badgeCount = tab.badgeCount, badgeCount > 0 {
                        VStack {
                            HStack {
                                Spacer()
                                BadgeView(count: badgeCount, color: appearance.badgeColor)
                                    .offset(x: 8, y: -8)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 28)
                
                // Title
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? appearance.selectedColor : appearance.unselectedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .animation(.easeInOut(duration: appearance.animationDuration), value: isSelected)
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let count: Int
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: count > 99 ? 24 : 18, height: 18)
            
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct TabBarController_Previews: PreviewProvider {
    static var previews: some View {
        TabBarController(tabs: [
            TabItem(title: "Home", icon: "house", selectedIcon: "house.fill") {
                Color.blue.ignoresSafeArea()
                    .overlay(Text("Home Tab").font(.largeTitle).foregroundColor(.white))
            },
            TabItem(title: "Search", icon: "magnifyingglass", badgeCount: 3) {
                Color.green.ignoresSafeArea()
                    .overlay(Text("Search Tab").font(.largeTitle).foregroundColor(.white))
            },
            TabItem(title: "Profile", icon: "person", selectedIcon: "person.fill", badgeCount: 12) {
                Color.orange.ignoresSafeArea()
                    .overlay(Text("Profile Tab").font(.largeTitle).foregroundColor(.white))
            }
        ])
    }
}