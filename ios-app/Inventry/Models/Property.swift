import Foundation

struct Property: Identifiable, Codable {
    let id: UUID
    var name: String
    var address: String
    var type: PropertyType
    var landlord: Landlord
    var tenant: Tenant?
    var inventoryType: InventoryType
    var status: PropertyStatus
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, address: String, type: PropertyType, landlord: Landlord, inventoryType: InventoryType) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.type = type
        self.landlord = landlord
        self.tenant = nil
        self.inventoryType = inventoryType
        self.status = .draft
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum PropertyType: String, CaseIterable, Codable {
    case house = "house"
    case flat = "flat"
    case maisonette = "maisonette"
    case bungalow = "bungalow"
    case studio = "studio"
    case bedsit = "bedsit"
    case commercial = "commercial"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .house: return "House"
        case .flat: return "Flat"
        case .maisonette: return "Maisonette"
        case .bungalow: return "Bungalow"
        case .studio: return "Studio"
        case .bedsit: return "Bedsit"
        case .commercial: return "Commercial"
        case .other: return "Other"
        }
    }
}

enum PropertyStatus: String, CaseIterable, Codable {
    case draft = "draft"
    case inProgress = "in_progress"
    case completed = "completed"
    case approved = "approved"
    case archived = "archived"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .approved: return "Approved"
        case .archived: return "Archived"
        }
    }
    
    var color: String {
        switch self {
        case .draft: return "gray"
        case .inProgress: return "blue"
        case .completed: return "green"
        case .approved: return "purple"
        case .archived: return "red"
        }
    }
}