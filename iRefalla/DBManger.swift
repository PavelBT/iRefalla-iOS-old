//
//  DBmanger.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 22/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import CoreData

fileprivate let appName = "iRefalla"

class DBManager {
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: appName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: User Function
    
    class func managedObject(entityName: String) -> NSManagedObject  {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
        let object = NSManagedObject(entity: entity!, insertInto: managedContext)
        return object
    }
    
    class func consulta <T: NSManagedObject>(entityClass: T.Type, filter: NSPredicate?) -> [T] {
        
        var array = [NSManagedObject]()
        let managedContext = persistentContainer.viewContext
        let name = NSStringFromClass(entityClass)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        fetchRequest.predicate = filter
        do {
            array = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return array as! [T]
    }
    
    class func delete <T: NSManagedObject>(entityClass: T.Type, filter: NSPredicate?) {
        let managedContext = persistentContainer.viewContext
        let array = self.consulta(entityClass: entityClass, filter: filter)
        
        do {
            for element in array {
                managedContext.delete(element)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}


// MARK: Extension

extension NSManagedObject {
    
    class func getAll() -> [NSManagedObject] {
        return DBManager.consulta(entityClass: self, filter: nil)
    }
    
    class func getByID(id: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "id == %@", id)
        let array = DBManager.consulta(entityClass: self, filter: predicate)
        if !array.isEmpty {return array[0]} else {return nil}
    }
    
    class func getFiltered(predicate: NSPredicate) -> [NSManagedObject]? {
        let array = DBManager.consulta(entityClass: self, filter: predicate)
        if !array.isEmpty {return array} else {return nil}
    }
    
    class func deleteAll() {
        DBManager.delete(entityClass: self, filter: nil)
    }
}
