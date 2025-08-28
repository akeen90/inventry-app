import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {
        print("🗄️ CoreDataStack initializing...")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "InventoryModel")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Core Data failed to load store: \(error.localizedDescription)")
                fatalError("Core Data error: \(error)")
            } else {
                print("✅ Core Data store loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("✅ Core Data context saved successfully")
        } catch {
            print("❌ Failed to save Core Data context: \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext()
        context.perform {
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                    print("✅ Background Core Data context saved")
                } catch {
                    print("❌ Failed to save background context: \(error.localizedDescription)")
                }
            }
        }
    }
}