import CoreData
import UIKit

extension TrackerCoreData {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = TrackerCoreData.nextAvailableID(in: self.managedObjectContext)
    }
    
    private static func nextAvailableID(in context: NSManagedObjectContext?) -> Int32 {
        guard let context else { return 1 }
        
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "TrackerCoreData")
        request.resultType = .dictionaryResultType
        
        let expressionDesc = NSExpressionDescription()
        expressionDesc.name = "maxID"
        expressionDesc.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "id")])
        expressionDesc.expressionResultType = .integer32AttributeType
        request.propertiesToFetch = [expressionDesc]
        
        do {
            let result = try context.fetch(request)
            let maxID = (result.first?["maxID"] as? Int32) ?? 0
            return maxID + 1
        } catch {
            Logger.error("Ошибка при получении nextAvailableID: \(error)")
            return 1
        }
    }
}
