import Foundation
import CoreData

extension PropertyEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PropertyEntity> {
        return NSFetchRequest<PropertyEntity>(entityName: "PropertyEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var type: String?
    @NSManaged public var status: String?
    @NSManaged public var inventoryType: String?
    @NSManaged public var landlordData: Data?
    @NSManaged public var tenantData: Data?
    @NSManaged public var propertyPhotoData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var lastAccessedAt: Date?
    @NSManaged public var isSynced: Bool
    @NSManaged public var needsUpload: Bool
    @NSManaged public var inventoryReport: InventoryReportEntity?
}