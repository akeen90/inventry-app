import Foundation
import CoreData
import Combine

class LocalStorageService: ObservableObject {
    static let shared = LocalStorageService()
    
    private let coreDataStack = CoreDataStack.shared
    private let maxCachedReports = 5
    
    @Published var cachedProperties: [Property] = []
    @Published var isLoading = false
    
    private init() {
        print("💾 LocalStorageService initializing...")
        loadCachedProperties()
    }
    
    // MARK: - LRU Cache Management
    
    func loadCachedProperties() {
        isLoading = true
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastAccessedAt", ascending: false)]
        request.fetchLimit = maxCachedReports
        
        do {
            let entities = try context.fetch(request)
            cachedProperties = entities.compactMap { convertToProperty($0) }
            print("✅ Loaded \(cachedProperties.count) cached properties")
        } catch {
            print("❌ Failed to load cached properties: \(error.localizedDescription)")
            cachedProperties = []
        }
        
        isLoading = false
    }
    
    func saveProperty(_ property: Property) {
        let context = coreDataStack.context
        
        // Check if property already exists
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", property.id.uuidString)
        
        do {
            let existingEntities = try context.fetch(request)
            let entity = existingEntities.first ?? PropertyEntity(context: context)
            
            updateEntity(entity, with: property)
            entity.lastAccessedAt = Date()
            entity.needsUpload = true
            entity.isSynced = false
            
            coreDataStack.saveContext()
            
            // Update LRU cache
            manageLRUCache(for: property)
            loadCachedProperties()
            
            print("✅ Property saved locally: \(property.name)")
        } catch {
            print("❌ Failed to save property locally: \(error.localizedDescription)")
        }
    }
    
    func updatePropertyAccess(_ propertyId: UUID) {
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", propertyId.uuidString)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.lastAccessedAt = Date()
                coreDataStack.saveContext()
                loadCachedProperties()
                print("📱 Updated access time for property: \(propertyId)")
            }
        } catch {
            print("❌ Failed to update property access time: \(error.localizedDescription)")
        }
    }
    
    private func manageLRUCache(for property: Property) {
        let context = coreDataStack.context
        
        // Count total stored properties
        let countRequest: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        
        do {
            let totalCount = try context.count(for: countRequest)
            
            if totalCount > maxCachedReports {
                // Remove oldest accessed properties beyond the limit
                let oldestRequest: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
                oldestRequest.sortDescriptors = [NSSortDescriptor(key: "lastAccessedAt", ascending: true)]
                oldestRequest.fetchLimit = totalCount - maxCachedReports
                
                let oldestEntities = try context.fetch(oldestRequest)
                
                for entity in oldestEntities {
                    print("🗑️ Removing old cached property: \(entity.name ?? "Unknown")")
                    context.delete(entity)
                }
                
                coreDataStack.saveContext()
            }
        } catch {
            print("❌ Failed to manage LRU cache: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Property Operations
    
    func getProperty(by id: UUID) -> Property? {
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do {
            if let entity = try context.fetch(request).first {
                updatePropertyAccess(id)
                return convertToProperty(entity)
            }
        } catch {
            print("❌ Failed to get property: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func deleteProperty(_ propertyId: UUID) {
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", propertyId.uuidString)
        
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            coreDataStack.saveContext()
            loadCachedProperties()
            
            print("✅ Property deleted from local storage")
        } catch {
            print("❌ Failed to delete property from local storage: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sync Status Management
    
    func getPropertiesNeedingUpload() -> [Property] {
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "needsUpload == true")
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { convertToProperty($0) }
        } catch {
            print("❌ Failed to get properties needing upload: \(error.localizedDescription)")
            return []
        }
    }
    
    func markPropertySynced(_ propertyId: UUID) {
        let context = coreDataStack.context
        
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", propertyId.uuidString)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.isSynced = true
                entity.needsUpload = false
                coreDataStack.saveContext()
                print("✅ Property marked as synced: \(propertyId)")
            }
        } catch {
            print("❌ Failed to mark property as synced: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Conversion Methods
    
    private func updateEntity(_ entity: PropertyEntity, with property: Property) {
        entity.id = property.id.uuidString
        entity.userId = property.userId
        entity.name = property.name
        entity.address = property.address
        entity.type = property.type.rawValue
        entity.status = property.status.rawValue
        entity.inventoryType = property.inventoryType.rawValue
        entity.createdAt = property.createdAt
        entity.updatedAt = property.updatedAt
        
        // Encode complex objects as JSON data
        if let landlordData = try? JSONEncoder().encode(property.landlord) {
            entity.landlordData = landlordData
        }
        
        if let tenant = property.tenant,
           let tenantData = try? JSONEncoder().encode(tenant) {
            entity.tenantData = tenantData
        }
        
        if let propertyPhoto = property.propertyPhoto,
           let photoData = try? JSONEncoder().encode(propertyPhoto) {
            entity.propertyPhotoData = photoData
        }
        
        // Handle inventory report
        if let inventoryReport = property.inventoryReport {
            updateInventoryReportEntity(entity, with: inventoryReport)
        }
    }
    
    private func updateInventoryReportEntity(_ propertyEntity: PropertyEntity, with report: InventoryReport) {
        let context = coreDataStack.context
        
        let reportEntity = propertyEntity.inventoryReport ?? InventoryReportEntity(context: context)
        reportEntity.id = report.id.uuidString
        reportEntity.completionPercentage = report.completionPercentage
        reportEntity.totalItems = Int32(report.totalItems)
        reportEntity.completedItems = Int32(report.completedItems)
        reportEntity.createdAt = report.createdAt
        reportEntity.updatedAt = report.updatedAt
        reportEntity.property = propertyEntity
        
        // Clear existing rooms
        if let existingRooms = reportEntity.rooms?.allObjects as? [RoomEntity] {
            for roomEntity in existingRooms {
                context.delete(roomEntity)
            }
        }
        
        // Add new rooms
        for room in report.rooms {
            let roomEntity = RoomEntity(context: context)
            roomEntity.id = room.id.uuidString
            roomEntity.name = room.name
            roomEntity.type = room.type.rawValue
            roomEntity.notes = room.notes
            roomEntity.createdAt = room.createdAt
            roomEntity.updatedAt = room.updatedAt
            roomEntity.inventoryReport = reportEntity
            
            // Add inventory items
            for item in room.items {
                let itemEntity = InventoryItemEntity(context: context)
                itemEntity.id = item.id.uuidString
                itemEntity.name = item.name
                itemEntity.itemDescription = item.description
                itemEntity.condition = item.condition.rawValue
                itemEntity.category = item.category.rawValue
                itemEntity.notes = item.notes
                itemEntity.createdAt = item.createdAt
                itemEntity.updatedAt = item.updatedAt
                itemEntity.room = roomEntity
                
                // Encode photos array
                if !item.photos.isEmpty,
                   let photosData = try? JSONEncoder().encode(item.photos) {
                    itemEntity.photosData = photosData
                }
            }
        }
        
        propertyEntity.inventoryReport = reportEntity
    }
    
    private func convertToProperty(_ entity: PropertyEntity) -> Property? {
        guard let idString = entity.id,
              let id = UUID(uuidString: idString),
              let name = entity.name,
              let address = entity.address,
              let typeString = entity.type,
              let type = PropertyType(rawValue: typeString),
              let statusString = entity.status,
              let status = PropertyStatus(rawValue: statusString),
              let inventoryTypeString = entity.inventoryType,
              let inventoryType = InventoryType(rawValue: inventoryTypeString) else {
            print("❌ Failed to convert PropertyEntity: missing required fields")
            return nil
        }
        
        // Decode landlord
        guard let landlordData = entity.landlordData,
              let landlord = try? JSONDecoder().decode(Landlord.self, from: landlordData) else {
            print("❌ Failed to decode landlord data")
            return nil
        }
        
        var property = Property(
            name: name,
            address: address,
            type: type,
            landlord: landlord,
            inventoryType: inventoryType,
            userId: entity.userId ?? ""
        )
        
        // Set additional properties
        property.id = id
        property.status = status
        property.createdAt = entity.createdAt ?? Date()
        property.updatedAt = entity.updatedAt ?? Date()
        
        // Decode optional fields
        if let tenantData = entity.tenantData {
            property.tenant = try? JSONDecoder().decode(Tenant.self, from: tenantData)
        }
        
        if let photoData = entity.propertyPhotoData {
            property.propertyPhoto = try? JSONDecoder().decode(PhotoReference.self, from: photoData)
        }
        
        // Convert inventory report
        if let reportEntity = entity.inventoryReport {
            property.inventoryReport = convertToInventoryReport(reportEntity)
        }
        
        return property
    }
    
    private func convertToInventoryReport(_ entity: InventoryReportEntity) -> InventoryReport? {
        guard let idString = entity.id,
              let id = UUID(uuidString: idString),
              let propertyEntity = entity.property,
              let propertyIdString = propertyEntity.id,
              let propertyId = UUID(uuidString: propertyIdString) else {
            return nil
        }
        
        var report = InventoryReport(propertyId: propertyId, inventoryType: .inventory)
        report.createdAt = entity.createdAt ?? Date()
        report.updatedAt = entity.updatedAt ?? Date()
        
        // Convert rooms
        if let roomEntities = entity.rooms?.allObjects as? [RoomEntity] {
            report.rooms = roomEntities.compactMap { convertToRoom($0) }
        }
        
        return report
    }
    
    private func convertToRoom(_ entity: RoomEntity) -> Room? {
        guard let idString = entity.id,
              let id = UUID(uuidString: idString),
              let name = entity.name,
              let typeString = entity.type,
              let type = RoomType(rawValue: typeString) else {
            return nil
        }
        
        var room = Room(name: name, type: type)
        room.id = id
        room.notes = entity.notes
        room.createdAt = entity.createdAt ?? Date()
        room.updatedAt = entity.updatedAt ?? Date()
        
        // Convert inventory items
        if let itemEntities = entity.items?.allObjects as? [InventoryItemEntity] {
            room.items = itemEntities.compactMap { convertToInventoryItem($0) }
        }
        
        return room
    }
    
    private func convertToInventoryItem(_ entity: InventoryItemEntity) -> InventoryItem? {
        guard let idString = entity.id,
              let id = UUID(uuidString: idString),
              let name = entity.name,
              let conditionString = entity.condition,
              let condition = ItemCondition(rawValue: conditionString),
              let categoryString = entity.category,
              let category = ItemCategory(rawValue: categoryString) else {
            return nil
        }
        
        var item = InventoryItem(name: name, category: category, condition: condition)
        item.id = id
        item.description = entity.itemDescription
        item.notes = entity.notes
        item.createdAt = entity.createdAt ?? Date()
        item.updatedAt = entity.updatedAt ?? Date()
        
        // Decode photos
        if let photosData = entity.photosData {
            item.photos = (try? JSONDecoder().decode([PhotoReference].self, from: photosData)) ?? []
        }
        
        return item
    }
}