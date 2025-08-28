import Foundation
import SwiftUI

// MARK: - Photo Reference Model
struct PhotoReference: Identifiable, Codable {
    let id: UUID
    var filename: String
    var localPath: String?
    var remoteURL: String?
    var uploadedAt: Date?
    var createdAt: Date
    
    // For holding UIImage temporarily (not codable - stored in memory)
    private var _originalImage: UIImage?
    
    var originalImage: UIImage? {
        get { _originalImage }
        set { _originalImage = newValue }
    }
    
    init(filename: String, originalImage: UIImage? = nil) {
        self.id = UUID()
        self.filename = filename
        self.localPath = nil
        self.remoteURL = nil
        self.uploadedAt = nil
        self.createdAt = Date()
        self._originalImage = originalImage
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, filename, localPath, remoteURL, uploadedAt, createdAt
    }
    
    // Custom init from decoder (doesn't include originalImage)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        filename = try container.decode(String.self, forKey: .filename)
        localPath = try container.decodeIfPresent(String.self, forKey: .localPath)
        remoteURL = try container.decodeIfPresent(String.self, forKey: .remoteURL)
        uploadedAt = try container.decodeIfPresent(Date.self, forKey: .uploadedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        _originalImage = nil
    }
    
    // Custom encode (doesn't include originalImage)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(filename, forKey: .filename)
        try container.encodeIfPresent(localPath, forKey: .localPath)
        try container.encodeIfPresent(remoteURL, forKey: .remoteURL)
        try container.encodeIfPresent(uploadedAt, forKey: .uploadedAt)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

// MARK: - Room Model
struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RoomType
    var items: [InventoryItem]
    var photos: [PhotoReference] // Room overview photos
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, type: RoomType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.items = []
        self.photos = []
        self.notes = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var itemCount: Int {
        items.count
    }
    
    var completedItemsCount: Int {
        items.filter { $0.isComplete }.count
    }
    
    var completionPercentage: Double {
        guard itemCount > 0 else { return 0.0 }
        return Double(completedItemsCount) / Double(itemCount) * 100.0
    }
}

enum RoomType: String, CaseIterable, Codable {
    case livingRoom = "living_room"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case hallway = "hallway"
    case diningRoom = "dining_room"
    case conservatory = "conservatory"
    case utility = "utility"
    case garage = "garage"
    case garden = "garden"
    case exterior = "exterior"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .bedroom: return "Bedroom"
        case .kitchen: return "Kitchen"
        case .bathroom: return "Bathroom"
        case .hallway: return "Hallway"
        case .diningRoom: return "Dining Room"
        case .conservatory: return "Conservatory"
        case .utility: return "Utility Room"
        case .garage: return "Garage"
        case .garden: return "Garden"
        case .exterior: return "Exterior"
        case .other: return "Other"
        }
    }
    
    var systemImage: String {
        switch self {
        case .livingRoom: return "sofa"
        case .bedroom: return "bed.double"
        case .kitchen: return "fork.knife"
        case .bathroom: return "bathtub"
        case .hallway: return "door.left.hand.open"
        case .diningRoom: return "table.furniture"
        case .conservatory: return "leaf"
        case .utility: return "washer"
        case .garage: return "car.garage"
        case .garden: return "tree"
        case .exterior: return "house"
        case .other: return "square.grid.3x3"
        }
    }
}

// MARK: - Inventory Item Model
struct InventoryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: ItemCategory
    var condition: ItemCondition
    var description: String?
    var photos: [PhotoReference] // Photo references with local/remote paths
    var notes: String?
    var isComplete: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, category: ItemCategory, condition: ItemCondition = .good) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.condition = condition
        self.description = nil
        self.photos = []
        self.notes = nil
        self.isComplete = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ItemCategory: String, CaseIterable, Codable {
    case furniture = "furniture"
    case appliances = "appliances"
    case fixtures = "fixtures"
    case flooring = "flooring"
    case walls = "walls"
    case windows = "windows"
    case doors = "doors"
    case lighting = "lighting"
    case heating = "heating"
    case plumbing = "plumbing"
    case electrical = "electrical"
    case security = "security"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .furniture: return "Furniture"
        case .appliances: return "Appliances"
        case .fixtures: return "Fixtures & Fittings"
        case .flooring: return "Flooring"
        case .walls: return "Walls & Decoration"
        case .windows: return "Windows"
        case .doors: return "Doors"
        case .lighting: return "Lighting"
        case .heating: return "Heating"
        case .plumbing: return "Plumbing"
        case .electrical: return "Electrical"
        case .security: return "Security"
        case .other: return "Other"
        }
    }
    
    var systemImage: String {
        switch self {
        case .furniture: return "chair"
        case .appliances: return "refrigerator"
        case .fixtures: return "wrench.and.screwdriver"
        case .flooring: return "square.grid.3x1.below.line.grid.1x2"
        case .walls: return "paintbrush"
        case .windows: return "rectangle.inset.filled"
        case .doors: return "door.left.hand.open"
        case .lighting: return "lightbulb"
        case .heating: return "thermometer"
        case .plumbing: return "drop"
        case .electrical: return "bolt"
        case .security: return "lock"
        case .other: return "square.grid.2x2"
        }
    }
}

enum ItemCondition: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case damaged = "damaged"
    case missing = "missing"
    
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .damaged: return "Damaged"
        case .missing: return "Missing"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor: return "red"
        case .damaged: return "red"
        case .missing: return "red"
        }
    }
}

// MARK: - Inventory Report Model
struct InventoryReport: Identifiable, Codable {
    let id: UUID
    let propertyId: UUID
    var inventoryType: InventoryType
    var rooms: [Room]
    var landlordSignature: String? // Base64 encoded signature
    var tenantSignature: String? // Base64 encoded signature
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(propertyId: UUID, inventoryType: InventoryType) {
        self.id = UUID()
        self.propertyId = propertyId
        self.inventoryType = inventoryType
        self.rooms = []
        self.landlordSignature = nil
        self.tenantSignature = nil
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var isComplete: Bool {
        return landlordSignature != nil && tenantSignature != nil && !rooms.isEmpty
    }
    
    var totalItems: Int {
        rooms.reduce(0) { $0 + $1.itemCount }
    }
    
    var completedItems: Int {
        rooms.reduce(0) { $0 + $1.completedItemsCount }
    }
    
    var completionPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(completedItems) / Double(totalItems) * 100.0
    }
}