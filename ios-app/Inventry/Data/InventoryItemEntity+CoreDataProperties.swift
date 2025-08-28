import Foundation
import CoreData

extension InventoryItemEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InventoryItemEntity> {
        return NSFetchRequest<InventoryItemEntity>(entityName: "InventoryItemEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var condition: String?
    @NSManaged public var category: String?
    @NSManaged public var notes: String?
    @NSManaged public var photosData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var room: RoomEntity?
}