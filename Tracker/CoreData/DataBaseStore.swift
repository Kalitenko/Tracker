import CoreData

final class DataBaseStore {
    
    // MARK: - Shared Instance
    static let shared = DataBaseStore()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            } else {
                Logger.debug("Core Data store loaded: \(storeDescription.url?.path ?? "no URL")")
            }
        })
        return container
    }()
    
    // MARK: - Initializers
    private init() {
        preloadInitialData()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Initial Data
    private func preloadInitialData() {
        let context = persistentContainer.viewContext
        let initializer = DataInitializer(context: context)
        initializer.preloadDataIfNeeded()
    }
}
