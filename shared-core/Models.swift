import Foundation

// MARK: - Property Models
struct Property: Identifiable, Codable {
    let id: UUID
    var name: String
    var address: String
    var type: PropertyType
    var landlord: Landlord
    var tenant: Tenant?
    var rooms: [Room]
    var createdAt: Date
    var updatedAt: Date
    var inventoryType: InventoryType
    var status: PropertyStatus
    
    init(name: String, address: String, type: PropertyType, landlord: Landlord, inventoryType: InventoryType) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.type = type
        self.landlord = landlord
        self.tenant = nil
        self.rooms = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.inventoryType = inventoryType
        self.status = .draft
    }
}

enum PropertyType: String, CaseIterable, Codable {
    case house = "house"
    case flat = "flat"
    case maisonette = "maisonette"
    case bedsit = "bedsit"
    case studio = "studio"
    case hmo = "hmo" // House in Multiple Occupation
    case commercial = "commercial"
    case other = "other"
}

enum InventoryType: String, CaseIterable, Codable {
    case checkIn = "check_in"
    case checkOut = "check_out"
    case midTerm = "mid_term"
    case maintenance = "maintenance"
    case renewal = "renewal"
}

enum PropertyStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case completed = "completed"
    case signed = "signed" // Signed off by tenant
    case disputed = "disputed"
    case archived = "archived"
}

// MARK: - Room Models
struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RoomType
    var items: [InventoryItem]
    var photos: [Photo]
    var notes: String
    var voiceNotes: [VoiceNote]
    var cleanliness: CleanlinessRating
    var overallCondition: ItemCondition
    var measurements: RoomMeasurements?
    var isInspectionComplete: Bool
    var inspectorSignature: String?
    var tenantSignature: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, type: RoomType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.items = []
        self.photos = []
        self.notes = ""
        self.voiceNotes = []
        self.cleanliness = .fair
        self.overallCondition = .good
        self.measurements = nil
        self.isInspectionComplete = false
        self.inspectorSignature = nil
        self.tenantSignature = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum RoomType: String, CaseIterable, Codable {
    case livingRoom = "living_room"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case diningRoom = "dining_room"
    case office = "office"
    case basement = "basement"
    case attic = "attic"
    case garage = "garage"
    case laundryRoom = "laundry_room"
    case hallway = "hallway"
    case closet = "closet"
    case pantry = "pantry"
    case balcony = "balcony"
    case patio = "patio"
    case other = "other"
}

// MARK: - Inventory Item Models
struct InventoryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: ItemCategory
    var condition: ItemCondition
    var description: String
    var quantity: Int
    var photos: [Photo]
    var serialNumber: String?
    var model: String?
    var brand: String?
    var purchaseDate: Date?
    var estimatedValue: Double?
    var location: String? // Specific location within room
    var isFixed: Bool // Built-in fixtures vs moveable items
    var damageNotes: String?
    var previousCondition: ItemCondition? // For check-out comparisons
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, category: ItemCategory, condition: ItemCondition) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.condition = condition
        self.description = ""
        self.quantity = 1
        self.photos = []
        self.serialNumber = nil
        self.model = nil
        self.brand = nil
        self.purchaseDate = nil
        self.estimatedValue = nil
        self.location = nil
        self.isFixed = false
        self.damageNotes = nil
        self.previousCondition = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ItemCategory: String, CaseIterable, Codable {
    case furniture = "furniture"
    case electronics = "electronics"
    case appliances = "appliances"
    case clothing = "clothing"
    case books = "books"
    case artwork = "artwork"
    case jewelry = "jewelry"
    case tools = "tools"
    case kitchenware = "kitchenware"
    case decorative = "decorative"
    case lighting = "lighting"
    case textiles = "textiles"
    case sports = "sports"
    case toys = "toys"
    case documents = "documents"
    case other = "other"
}

enum ItemCondition: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case damaged = "damaged"
    case needsRepair = "needs_repair"
}

// MARK: - Photo Models
struct Photo: Identifiable, Codable {
    let id: UUID
    var filename: String
    var caption: String
    var url: String?
    var thumbnailUrl: String?
    var createdAt: Date
    
    init(filename: String, caption: String = "") {
        self.id = UUID()
        self.filename = filename
        self.caption = caption
        self.url = nil
        self.thumbnailUrl = nil
        self.createdAt = Date()
    }
}

// MARK: - Landlord & Tenant Models
struct Landlord: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var address: String?
    var company: String?
    var portfolio: [UUID] // Property IDs
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = nil
        self.address = nil
        self.company = nil
        self.portfolio = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Tenant: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var emergencyContact: EmergencyContact?
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
        self.emergencyContact = nil
        self.tenancyStartDate = nil
        self.tenancyEndDate = nil
        self.depositAmount = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct EmergencyContact: Codable {
    var name: String
    var phone: String
    var relationship: String
}

// MARK: - Report Models  
struct InventoryReport: Identifiable, Codable {
    let id: UUID
    var property: Property
    var generatedAt: Date
    var format: ReportFormat
    var status: ReportStatus
    var url: String?
    var summary: ReportSummary
    
    init(property: Property, format: ReportFormat) {
        self.id = UUID()
        self.property = property
        self.generatedAt = Date()
        self.format = format
        self.status = .generating
        self.url = nil
        self.summary = ReportSummary(property: property)
    }
}

enum ReportFormat: String, CaseIterable, Codable {
    case pdf = "pdf"
    case excel = "excel"
    case csv = "csv"
    case json = "json"
}

enum ReportStatus: String, CaseIterable, Codable {
    case generating = "generating"
    case ready = "ready"
    case failed = "failed"
    case expired = "expired"
}

struct ReportSummary: Codable {
    let totalRooms: Int
    let totalItems: Int
    let totalEstimatedValue: Double
    let itemsByCategory: [ItemCategory: Int]
    let itemsByCondition: [ItemCondition: Int]
    
    init(property: Property) {
        self.totalRooms = property.rooms.count
        self.totalItems = property.rooms.reduce(0) { $0 + $1.items.count }
        self.totalEstimatedValue = property.rooms.flatMap { $0.items }
            .compactMap { $0.estimatedValue }
            .reduce(0, +)
        
        let allItems = property.rooms.flatMap { $0.items }
        self.itemsByCategory = Dictionary(grouping: allItems, by: { $0.category })
            .mapValues { $0.count }
        self.itemsByCondition = Dictionary(grouping: allItems, by: { $0.condition })
            .mapValues { $0.count }
    }
}

// MARK: - User Models
struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var name: String
    var role: UserRole
    var company: String?
    var isActive: Bool
    var createdAt: Date
    var lastLoginAt: Date?
    
    init(email: String, name: String, role: UserRole) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.role = role
        self.company = nil
        self.isActive = true
        self.createdAt = Date()
        self.lastLoginAt = nil
    }
}

enum UserRole: String, CaseIterable, Codable {
    case admin = "admin"
    case inspector = "inspector"
    case client = "client"
    case viewer = "viewer"
}

// MARK: - Supporting Models

struct VoiceNote: Identifiable, Codable {
    let id: UUID
    var filename: String
    var duration: TimeInterval
    var transcription: String?
    var url: String?
    var createdAt: Date
    
    init(filename: String, duration: TimeInterval) {
        self.id = UUID()
        self.filename = filename
        self.duration = duration
        self.transcription = nil
        self.url = nil
        self.createdAt = Date()
    }
}

enum CleanlinessRating: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good" 
    case fair = "fair"
    case poor = "poor"
    case unacceptable = "unacceptable"
}

struct RoomMeasurements: Codable {
    var length: Double
    var width: Double
    var height: Double
    var unit: MeasurementUnit = .meters
    
    var area: Double {
        return length * width
    }
    
    var volume: Double {
        return length * width * height
    }
}

enum MeasurementUnit: String, CaseIterable, Codable {
    case meters = "m"
    case feet = "ft"
    case inches = "in"
}

// MARK: - Inspection Workflow Models

struct InspectionChecklist: Identifiable, Codable {
    let id: UUID
    var name: String
    var roomType: RoomType
    var checklistItems: [ChecklistItem]
    var isDefault: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, roomType: RoomType) {
        self.id = UUID()
        self.name = name
        self.roomType = roomType
        self.checklistItems = []
        self.isDefault = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct ChecklistItem: Identifiable, Codable {
    let id: UUID
    var description: String
    var category: ItemCategory
    var isRequired: Bool
    var defaultCondition: ItemCondition
    var inspectionTips: String?
    
    init(description: String, category: ItemCategory, isRequired: Bool = true) {
        self.id = UUID()
        self.description = description
        self.category = category
        self.isRequired = isRequired
        self.defaultCondition = .good
        self.inspectionTips = nil
    }
}