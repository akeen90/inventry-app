import SwiftUI

// MARK: - Inventry Branding System
struct InventryBrand {
    
    // MARK: - Brand Colors
    struct Colors {
        // Primary Brand Colors
        static let primaryBlue = Color(red: 0.2, green: 0.4, blue: 0.8)        // #3366CC
        static let primaryPurple = Color(red: 0.5, green: 0.2, blue: 0.8)      // #8033CC
        static let primaryGradient = LinearGradient(
            colors: [primaryBlue, primaryPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Secondary Colors
        static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)       // #FF9933
        static let accentGreen = Color(red: 0.2, green: 0.7, blue: 0.4)        // #33B366
        static let accentRed = Color(red: 0.9, green: 0.3, blue: 0.3)          // #E64D4D
        
        // Neutral Colors
        static let neutralDark = Color(red: 0.15, green: 0.15, blue: 0.2)      // #26262E
        static let neutralMedium = Color(red: 0.4, green: 0.4, blue: 0.5)      // #666680
        static let neutralLight = Color(red: 0.95, green: 0.95, blue: 0.97)    // #F2F2F7
        
        // Status Colors
        static let successGreen = Color(red: 0.2, green: 0.78, blue: 0.35)     // #34C759
        static let warningYellow = Color(red: 1.0, green: 0.8, blue: 0.0)      // #FFCC00
        static let errorRed = Color(red: 1.0, green: 0.23, blue: 0.19)         // #FF3B30
        
        // Background Gradients
        static let backgroundGradient = LinearGradient(
            colors: [Color(.systemBackground), neutralLight.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardGradient = LinearGradient(
            colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography System
    struct Typography {
        // Headlines
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 22, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Body Text
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        
        // Support Text
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption1 = Font.system(size: 12, weight: .medium, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing System
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius System
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Shadow System
    struct Shadows {
        static let subtle = Shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        static let strong = Shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        static let accent = Shadow(color: Colors.primaryBlue.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Brand Components

// Brand Logo Component
struct InventryLogo: View {
    let size: LogoSize
    let style: LogoStyle
    
    enum LogoSize {
        case small, medium, large, extraLarge
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            case .extraLarge: return 80
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 20
            case .large: return 28
            case .extraLarge: return 34
            }
        }
    }
    
    enum LogoStyle {
        case full, icon, text
    }
    
    var body: some View {
        HStack(spacing: InventryBrand.Spacing.sm) {
            if style != .text {
                // Logo Icon
                ZStack {
                    RoundedRectangle(cornerRadius: size.dimension * 0.25)
                        .fill(InventryBrand.Colors.primaryGradient)
                        .frame(width: size.dimension, height: size.dimension)
                        .shadow(color: InventryBrand.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "house.lodge.fill")
                        .font(.system(size: size.dimension * 0.5, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            if style != .icon {
                // Logo Text
                VStack(alignment: .leading, spacing: 0) {
                    Text("Inventry")
                        .font(.system(size: size.fontSize, weight: .bold, design: .default))
                        .foregroundStyle(InventryBrand.Colors.primaryGradient)
                    
                    if size != .small {
                        Text("Property Inventory")
                            .font(.system(size: size.fontSize * 0.4, weight: .medium))
                            .foregroundColor(InventryBrand.Colors.neutralMedium)
                    }
                }
            }
        }
    }
}

// Brand Button Component
struct InventryButton: View {
    let title: String
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary, secondary, tertiary, accent, success, warning, danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return InventryBrand.Colors.primaryBlue
            case .secondary: return Color(.systemGray5)
            case .tertiary: return Color.clear
            case .accent: return InventryBrand.Colors.accentOrange
            case .success: return InventryBrand.Colors.successGreen
            case .warning: return InventryBrand.Colors.warningYellow
            case .danger: return InventryBrand.Colors.errorRed
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .accent, .success, .danger: return .white
            case .secondary: return .primary
            case .tertiary: return InventryBrand.Colors.primaryBlue
            case .warning: return .black
            }
        }
        
        var backgroundGradient: LinearGradient? {
            switch self {
            case .primary: return InventryBrand.Colors.primaryGradient
            case .accent: return LinearGradient(colors: [InventryBrand.Colors.accentOrange, InventryBrand.Colors.accentOrange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            default: return nil
            }
        }
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return InventryBrand.Typography.footnote.weight(.semibold)
            case .medium: return InventryBrand.Typography.callout.weight(.semibold)
            case .large: return InventryBrand.Typography.headline
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return InventryBrand.CornerRadius.sm
            case .medium: return InventryBrand.CornerRadius.md
            case .large: return InventryBrand.CornerRadius.lg
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(style.foregroundColor)
                .padding(size.padding)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if let gradient = style.backgroundGradient {
                            gradient
                        } else {
                            style.backgroundColor
                        }
                    }
                )
                .cornerRadius(size.cornerRadius)
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .shadow(
                    color: style == .primary ? InventryBrand.Colors.primaryBlue.opacity(0.3) : .black.opacity(0.1),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// Brand Card Component
struct InventryCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    
    enum CardStyle {
        case standard, elevated, gradient, accent
        
        var backgroundColor: Color {
            switch self {
            case .standard, .elevated: return Color(.systemBackground)
            case .gradient, .accent: return Color(.systemBackground)
            }
        }
        
        var backgroundGradient: LinearGradient? {
            switch self {
            case .gradient: return InventryBrand.Colors.cardGradient
            default: return nil
            }
        }
        
        var shadow: Shadow {
            switch self {
            case .standard: return InventryBrand.Shadows.subtle
            case .elevated: return InventryBrand.Shadows.medium
            case .gradient: return InventryBrand.Shadows.strong
            case .accent: return InventryBrand.Shadows.accent
            }
        }
    }
    
    init(style: CardStyle = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(InventryBrand.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: InventryBrand.CornerRadius.lg)
                    .fill(style.backgroundGradient ?? AnyGradient(style.backgroundColor))
                    .shadow(
                        color: style.shadow.color,
                        radius: style.shadow.radius,
                        x: style.shadow.x,
                        y: style.shadow.y
                    )
            )
    }
}

// Brand Status Badge Component
struct InventryStatusBadge: View {
    let text: String
    let status: StatusType
    
    enum StatusType {
        case success, warning, error, info, neutral
        
        var color: Color {
            switch self {
            case .success: return InventryBrand.Colors.successGreen
            case .warning: return InventryBrand.Colors.warningYellow
            case .error: return InventryBrand.Colors.errorRed
            case .info: return InventryBrand.Colors.primaryBlue
            case .neutral: return InventryBrand.Colors.neutralMedium
            }
        }
        
        var backgroundColor: Color {
            return color.opacity(0.15)
        }
        
        var foregroundColor: Color {
            switch self {
            case .warning: return .black
            default: return color
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(InventryBrand.Typography.caption1)
            .foregroundColor(status.foregroundColor)
            .padding(.horizontal, InventryBrand.Spacing.sm)
            .padding(.vertical, InventryBrand.Spacing.xs)
            .background(
                Capsule()
                    .fill(status.backgroundColor)
            )
    }
}

// Brand Progress View
struct InventryProgressView: View {
    let progress: Double
    let style: ProgressStyle
    
    enum ProgressStyle {
        case linear, circular, ring
    }
    
    var body: some View {
        switch style {
        case .linear:
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: InventryBrand.CornerRadius.sm / 2)
                        .fill(InventryBrand.Colors.neutralLight)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: InventryBrand.CornerRadius.sm / 2)
                        .fill(InventryBrand.Colors.primaryGradient)
                        .frame(
                            width: geometry.size.width * progress,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
            
        case .circular:
            ZStack {
                Circle()
                    .stroke(InventryBrand.Colors.neutralLight, lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        InventryBrand.Colors.primaryGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                Text(String(format: "%.0f%%", progress * 100))
                    .font(InventryBrand.Typography.caption1)
                    .foregroundColor(.primary)
            }
            
        case .ring:
            ZStack {
                Circle()
                    .stroke(InventryBrand.Colors.neutralLight, lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        InventryBrand.Colors.primaryGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 40, height: 40)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
    }
}

// MARK: - Extensions

extension AnyGradient {
    init(_ color: Color) {
        self = AnyGradient(LinearGradient(colors: [color], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

extension Shadow {
    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        // This would be a custom implementation in a real app
        // For now, we'll use the built-in shadow modifier
    }
}

// Press Events Extension
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.modifier(PressEventModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct PressEventModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

// MARK: - Brand Preview
struct BrandingSystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: InventryBrand.Spacing.xl) {
                // Logo Variations
                VStack(spacing: InventryBrand.Spacing.lg) {
                    Text("Logo System")
                        .font(InventryBrand.Typography.title2)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: InventryBrand.Spacing.lg) {
                        InventryLogo(size: .small, style: .full)
                        InventryLogo(size: .medium, style: .icon)
                        InventryLogo(size: .large, style: .text)
                    }
                }
                
                // Button Variations
                VStack(spacing: InventryBrand.Spacing.lg) {
                    Text("Button System")
                        .font(InventryBrand.Typography.title2)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: InventryBrand.Spacing.md) {
                        InventryButton(title: "Primary Button", style: .primary, size: .large) {}
                        InventryButton(title: "Secondary Button", style: .secondary, size: .medium) {}
                        InventryButton(title: "Accent Button", style: .accent, size: .small) {}
                    }
                }
                
                // Status Badges
                VStack(spacing: InventryBrand.Spacing.lg) {
                    Text("Status Badges")
                        .font(InventryBrand.Typography.title2)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: InventryBrand.Spacing.md) {
                        InventryStatusBadge(text: "Complete", status: .success)
                        InventryStatusBadge(text: "In Progress", status: .info)
                        InventryStatusBadge(text: "Warning", status: .warning)
                        InventryStatusBadge(text: "Error", status: .error)
                    }
                }
                
                // Progress Views
                VStack(spacing: InventryBrand.Spacing.lg) {
                    Text("Progress System")
                        .font(InventryBrand.Typography.title2)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: InventryBrand.Spacing.md) {
                        InventryProgressView(progress: 0.75, style: .linear)
                        
                        HStack(spacing: InventryBrand.Spacing.lg) {
                            InventryProgressView(progress: 0.6, style: .circular)
                            InventryProgressView(progress: 0.85, style: .ring)
                        }
                    }
                }
                
                // Card Examples
                VStack(spacing: InventryBrand.Spacing.lg) {
                    Text("Card System")
                        .font(InventryBrand.Typography.title2)
                        .foregroundColor(.primary)
                    
                    InventryCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: InventryBrand.Spacing.sm) {
                            Text("Sample Card")
                                .font(InventryBrand.Typography.headline)
                                .foregroundColor(.primary)
                            
                            Text("This is an example of the brand card component with elevated shadow.")
                                .font(InventryBrand.Typography.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(InventryBrand.Spacing.lg)
        }
        .background(InventryBrand.Colors.backgroundGradient)
    }
}

#Preview {
    BrandingSystemPreview()
}