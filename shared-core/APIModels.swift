import Foundation

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: APIError?
    let message: String?
    
    init(data: T) {
        self.success = true
        self.data = data
        self.error = nil
        self.message = nil
    }
    
    init(error: APIError, message: String? = nil) {
        self.success = false
        self.data = nil
        self.error = error
        self.message = message
    }
}

struct APIError: Codable {
    let code: String
    let message: String
    let details: [String: String]?
}

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let refreshToken: String
    let user: User
    let expiresAt: Date
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let company: String?
}

// MARK: - Property API Models
struct CreatePropertyRequest: Codable {
    let name: String
    let address: String
    let type: PropertyType
    let clientId: UUID
}

struct UpdatePropertyRequest: Codable {
    let name: String?
    let address: String?
    let type: PropertyType?
    let status: PropertyStatus?
}

struct PropertyListResponse: Codable {
    let properties: [PropertySummary]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

struct PropertySummary: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let type: PropertyType
    let status: PropertyStatus
    let clientName: String
    let roomCount: Int
    let itemCount: Int
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Room API Models
struct CreateRoomRequest: Codable {
    let name: String
    let type: RoomType
    let propertyId: UUID
}

struct UpdateRoomRequest: Codable {
    let name: String?
    let type: RoomType?
    let notes: String?
}

// MARK: - Inventory Item API Models
struct CreateInventoryItemRequest: Codable {
    let name: String
    let category: ItemCategory
    let condition: ItemCondition
    let description: String?
    let estimatedValue: Double?
    let serialNumber: String?
    let model: String?
    let brand: String?
    let purchaseDate: Date?
    let roomId: UUID
}

struct UpdateInventoryItemRequest: Codable {
    let name: String?
    let category: ItemCategory?
    let condition: ItemCondition?
    let description: String?
    let estimatedValue: Double?
    let serialNumber: String?
    let model: String?
    let brand: String?
    let purchaseDate: Date?
}

// MARK: - Photo API Models
struct PhotoUploadRequest: Codable {
    let filename: String
    let caption: String?
    let itemId: UUID?
    let roomId: UUID?
}

struct PhotoUploadResponse: Codable {
    let photoId: UUID
    let uploadUrl: String
    let publicUrl: String
}

// MARK: - Client API Models
struct CreateClientRequest: Codable {
    let name: String
    let email: String
    let phone: String?
    let address: String?
    let company: String?
}

struct UpdateClientRequest: Codable {
    let name: String?
    let email: String?
    let phone: String?
    let address: String?
    let company: String?
}

struct ClientListResponse: Codable {
    let clients: [Client]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

// MARK: - Report API Models
struct GenerateReportRequest: Codable {
    let propertyId: UUID
    let format: ReportFormat
    let includePhotos: Bool
    let includeEstimatedValues: Bool
}

struct ReportListResponse: Codable {
    let reports: [InventoryReport]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

// MARK: - Search Models
struct SearchRequest: Codable {
    let query: String
    let filters: SearchFilters?
    let sortBy: String?
    let sortOrder: SortOrder?
    let page: Int?
    let pageSize: Int?
}

struct SearchFilters: Codable {
    let propertyTypes: [PropertyType]?
    let propertyStatuses: [PropertyStatus]?
    let roomTypes: [RoomType]?
    let itemCategories: [ItemCategory]?
    let itemConditions: [ItemCondition]?
    let dateRange: DateRange?
    let valueRange: ValueRange?
}

struct DateRange: Codable {
    let startDate: Date
    let endDate: Date
}

struct ValueRange: Codable {
    let minValue: Double
    let maxValue: Double
}

enum SortOrder: String, CaseIterable, Codable {
    case ascending = "asc"
    case descending = "desc"
}

// MARK: - Dashboard Analytics Models
struct DashboardAnalytics: Codable {
    let totalProperties: Int
    let activeProperties: Int
    let totalRooms: Int
    let totalItems: Int
    let totalEstimatedValue: Double
    let propertiesByType: [PropertyType: Int]
    let propertiesByStatus: [PropertyStatus: Int]
    let itemsByCategory: [ItemCategory: Int]
    let recentActivity: [ActivityEvent]
}

struct ActivityEvent: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let description: String
    let timestamp: Date
    let userId: UUID
    let propertyId: UUID?
    let roomId: UUID?
    let itemId: UUID?
}

enum ActivityType: String, CaseIterable, Codable {
    case propertyCreated = "property_created"
    case propertyUpdated = "property_updated"
    case roomCreated = "room_created"
    case roomUpdated = "room_updated"
    case itemCreated = "item_created"
    case itemUpdated = "item_updated"
    case photoUploaded = "photo_uploaded"
    case reportGenerated = "report_generated"
    case userLogin = "user_login"
}