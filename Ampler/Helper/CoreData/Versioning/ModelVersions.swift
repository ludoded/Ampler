import CoreData
import UIKit

enum Version: String {
    case version1 = "Ampler"
    case version2 = "Ampler v2"
}

extension Version: ModelVersion {
    static var all: [Version] {
        return [.version2, .version1]
    }
    
    static var current: Version { return .version1 }
    
    var name: String { return rawValue }
    var modelBundle: Bundle { return Bundle(for: Ampler.self) }
    var modelDirectoryName: String { return "Ampler.momd" }
    
    var successor: Version? {
        switch self {
        case .version1: return .version2
        default: return nil
        }
    }
    
    func mappingModelsToSuccessor() -> [NSMappingModel]? {
        switch self {
        case .version1:
            let mapping = try! NSMappingModel.inferredMappingModel(forSourceModel: managedObjectModel(),
                                                                   destinationModel: successor!.managedObjectModel())
            return [mapping]
        default:
            guard let mapping = mappingModelToSuccessor() else { return nil }
            return [mapping]
        }
    }
}

public final class Ampler: NSManagedObject {}
