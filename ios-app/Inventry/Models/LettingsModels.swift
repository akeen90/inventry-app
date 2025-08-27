import Foundation

// MARK: - Landlord & Tenant Models for iOS
struct Landlord: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var address: String?
    var company: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = nil
        self.address = nil
        self.company = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Tenant: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var tenancyStartDate: Date?
    var tenancyEndDate: Date?
    var depositAmount: Double?
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = nil
        self.tenancyStartDate = nil
        self.tenancyEndDate = nil
        self.depositAmount = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum InventoryType: String, CaseIterable, Codable {
    case checkIn = "check_in"
    case checkOut = "check_out"
    case midTerm = "mid_term"
    case maintenance = "maintenance"
    case renewal = "renewal"
    
    var displayName: String {
        switch self {
        case .checkIn: return "Check-in"
        case .checkOut: return "Check-out"
        case .midTerm: return "Mid-term"
        case .maintenance: return "Maintenance"
        case .renewal: return "Renewal"
        }
    }
}