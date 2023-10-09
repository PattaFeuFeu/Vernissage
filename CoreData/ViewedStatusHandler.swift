//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import PixelfedKit

class ViewedStatusHandler {
    public static let shared = ViewedStatusHandler()
    private init() { }

    func createViewedStatusEntity(viewContext: NSManagedObjectContext? = nil) -> ViewedStatus {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return ViewedStatus(context: context)
    }
    
    /// Check if given status (real picture) has been already visible on the timeline (during last month).
    func hasBeenAlreadyOnTimeline(accountId: String, status: Status, viewContext: NSManagedObjectContext? = nil) -> Bool {
        guard let reblog = status.reblog else {
            return false
        }

        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = ViewedStatus.fetchRequest()

        fetchRequest.fetchLimit = 1
        let statusIdPredicate = NSPredicate(format: "id = %@", reblog.id)
        let reblogIdPredicate = NSPredicate(format: "reblogId = %@", reblog.id)
        let idPredicates = NSCompoundPredicate.init(type: .or, subpredicates: [statusIdPredicate, reblogIdPredicate])
        
        let accountPredicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [idPredicates, accountPredicate])

        do {
            guard let first = try context.fetch(fetchRequest).first else {
                return false
            }
            
            if first.reblogId == nil {
                return true
            }
            
            if first.id != status.id {
                return true
            }
            
            return false
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching viewed statuses (hasBeenAlreadyOnTimeline).")
            return false
        }
    }
    
    /// Mark to delete statuses older then one month.
    func deleteOldViewedStatuses(viewContext: NSManagedObjectContext? = nil) {
        let oldViewedStatuses = self.getOldViewedStatuses(viewContext: viewContext)
        for status in oldViewedStatuses {
            viewContext?.delete(status)
        }
    }
    
    private func getOldViewedStatuses(viewContext: NSManagedObjectContext? = nil) -> [ViewedStatus] {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        
        guard let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }
        
        do {
            let fetchRequest = ViewedStatus.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date < %@", date as NSDate)

            return try context.fetch(fetchRequest)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching viewed statuses (getOldViewedStatuses).")
            return []
        }
    }
}