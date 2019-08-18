import Foundation
import CoreData

private let ubiquityToken: String = {
    guard let token = FileManager.default.ubiquityIdentityToken else { return "unknown" }
    let string = NSKeyedArchiver.archivedData(withRootObject: token).base64EncodedString(options: [])
    return string.removingCharacters(in: CharacterSet.letters.inverted)
}()

private let storeURL = URL.documents.appendingPathComponent("\(ubiquityToken).ampler")

final class PersistentStoreManager {
    static let shared = PersistentStoreManager()
    
    var currentContainer: NSPersistentContainer?
    
    var moc: NSManagedObjectContext? {
        return currentContainer?.viewContext
    }
    
    private let amplerContainer: NSPersistentContainer = {
        let momdName = "Ampler"
        let container = NSPersistentContainer(name: momdName, managedObjectModel: Version.current.managedObjectModel())
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = false
        container.persistentStoreDescriptions = [storeDescription]
        return container
    }()
    
    private init() {}
    
    func createMoodyContainer(migrating: Bool = false, progress: Progress? = nil, completion: @escaping (NSPersistentContainer) -> ()) {
        amplerContainer.loadPersistentStores { [weak self] _, error in
            guard let sSelf = self else { fatalError("Failed to load store: \(error!)") }
            
            if error == nil {
                DispatchQueue.main.async { completion(sSelf.amplerContainer) }
                
                self?.currentContainer = sSelf.amplerContainer
                self?.moc?.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            } else {
                guard !migrating else { fatalError("was unable to migrate store") }
                DispatchQueue.global(qos: .userInitiated).async {
                    migrateStore(from: storeURL, to: storeURL, targetVersion: Version.current, deleteSource: true, progress: progress)
                    self?.createMoodyContainer(migrating: true, progress: progress,
                                               completion: completion)
                }
            }
        }
    }
}
