import Foundation

// MARK: - Deleted Item Types
struct DeletedItem: Identifiable, Codable {
    let id: UUID
    let type: DeletedItemType
    let propertyId: UUID
    let propertyName: String
    let deletedAt: Date
    let data: Data // JSON encoded original item
    
    init<T: Codable>(item: T, type: DeletedItemType, propertyId: UUID, propertyName: String) {
        self.id = UUID()
        self.type = type
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.deletedAt = Date()
        
        do {
            self.data = try JSONEncoder().encode(item)
        } catch {
            print("❌ Failed to encode deleted item: \(error)")
            self.data = Data()
        }
    }
    
    func decode<T: Codable>(as type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("❌ Failed to decode deleted item: \(error)")
            return nil
        }
    }
}

enum DeletedItemType: String, Codable, CaseIterable {
    case property = "property"
    case room = "room"
    case inventoryItem = "inventory_item"
    
    var displayName: String {
        switch self {
        case .property: return "Property"
        case .room: return "Room"
        case .inventoryItem: return "Item"
        }
    }
    
    var systemImage: String {
        switch self {
        case .property: return "house"
        case .room: return "door.left.hand.open"
        case .inventoryItem: return "square.grid.3x3"
        }
    }
}

@MainActor
class DeletedItemsService: ObservableObject {
    static let shared = DeletedItemsService()
    
    @Published var deletedItems: [DeletedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let maxDeletedProperties = 10
    
    private init() {
        loadDeletedItems()
    }
    
    // MARK: - Loading and Persistence
    
    private func loadDeletedItems() {
        // For now, use in-memory storage
        // TODO: Integrate with Core Data when activated
        deletedItems = []
        print("📁 Loaded \(deletedItems.count) deleted items")
    }
    
    private func saveDeletedItems() {
        // For now, items are only stored in memory
        // TODO: Integrate with Core Data when activated
        print("💾 Saved \(deletedItems.count) deleted items")
    }
    
    // MARK: - Delete Operations
    
    func deleteProperty(_ property: Property) {
        let deletedProperty = DeletedItem(
            item: property,
            type: .property,
            propertyId: property.id,
            propertyName: property.name
        )
        
        deletedItems.append(deletedProperty)
        cleanupOldProperties()
        saveDeletedItems()
        
        print("🗑️ Moved property '\(property.name)' to deleted folder")
    }
    
    func deleteRoom(_ room: Room, propertyId: UUID, propertyName: String) {
        let deletedRoom = DeletedItem(
            item: room,
            type: .room,
            propertyId: propertyId,
            propertyName: propertyName
        )
        
        deletedItems.append(deletedRoom)
        saveDeletedItems()
        
        print("🗑️ Moved room '\(room.name)' to deleted folder")
    }
    
    func deleteInventoryItem(_ item: InventoryItem, roomName: String, propertyId: UUID, propertyName: String) {
        // Create extended item data that includes room context
        let extendedItem = DeletedInventoryItem(item: item, roomName: roomName)
        
        let deletedItem = DeletedItem(
            item: extendedItem,
            type: .inventoryItem,
            propertyId: propertyId,
            propertyName: propertyName
        )
        
        deletedItems.append(deletedItem)
        saveDeletedItems()
        
        print("🗑️ Moved item '\(item.name)' from '\(roomName)' to deleted folder")
    }
    
    // MARK: - Restore Operations
    
    func restoreItem(_ deletedItem: DeletedItem) -> (success: Bool, restoredItem: Any?) {
        switch deletedItem.type {
        case .property:
            if let property = deletedItem.decode(as: Property.self) {
                removeFromDeleted(deletedItem)
                return (true, property)
            }
        case .room:
            if let room = deletedItem.decode(as: Room.self) {
                removeFromDeleted(deletedItem)
                return (true, room)
            }
        case .inventoryItem:
            if let extendedItem = deletedItem.decode(as: DeletedInventoryItem.self) {
                removeFromDeleted(deletedItem)
                return (true, extendedItem)
            }
        }
        
        return (false, nil)
    }
    
    func permanentlyDelete(_ deletedItem: DeletedItem) {
        removeFromDeleted(deletedItem)
        print("💀 Permanently deleted \(deletedItem.type.displayName)")
    }
    
    private func removeFromDeleted(_ deletedItem: DeletedItem) {
        deletedItems.removeAll { $0.id == deletedItem.id }
        saveDeletedItems()
    }
    
    // MARK: - Cleanup
    
    private func cleanupOldProperties() {
        let properties = deletedItems.filter { $0.type == .property }
        if properties.count > maxDeletedProperties {
            // Remove oldest properties beyond the limit
            let sortedProperties = properties.sorted { $0.deletedAt < $1.deletedAt }
            let toRemove = sortedProperties.prefix(properties.count - maxDeletedProperties)
            
            for item in toRemove {
                deletedItems.removeAll { $0.id == item.id }
                print("🧹 Auto-cleaned old deleted property: \(item.propertyName)")
            }
        }
    }
    
    func clearAllDeleted() {
        deletedItems.removeAll()
        saveDeletedItems()
        print("🧹 Cleared all deleted items")
    }
    
    // MARK: - Utility
    
    func getDeletedItemsForProperty(_ propertyId: UUID) -> [DeletedItem] {
        return deletedItems.filter { $0.propertyId == propertyId }
    }
    
    func getDeletedItemsByType(_ type: DeletedItemType) -> [DeletedItem] {
        return deletedItems.filter { $0.type == type }
    }
}

// MARK: - Extended Item for Context
struct DeletedInventoryItem: Codable {
    let item: InventoryItem
    let roomName: String
    
    init(item: InventoryItem, roomName: String) {
        self.item = item
        self.roomName = roomName
    }
}