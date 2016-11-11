//
//  CoreDataStack.swift
//  iFunds
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation
import CoreData

typealias InitCallbackBlock = (()->())
class CoreDataStack {
    var mainContext : NSManagedObjectContext
    var writerContext : NSManagedObjectContext
    private var callBack : InitCallbackBlock?
    
    init?(callBack:InitCallbackBlock?) {
        self.callBack = callBack
        let modelURLOpt = Bundle.main.url(forResource: "SchemeModel", withExtension: "momd")
        guard let modelURL = modelURLOpt else { return nil }
        let modelOpt = NSManagedObjectModel(contentsOf: modelURL)
        guard let model = modelOpt else { return nil }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.writerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.writerContext.persistentStoreCoordinator = psc
        self.mainContext.parent = self.writerContext
        
        DispatchQueue.global(qos: .background).async {
            let psc = self.writerContext.persistentStoreCoordinator
            let defaultFileManager = FileManager.default
            let documentsURL = defaultFileManager.urls(for: .documentDirectory, in: .userDomainMask).last
            let options = [
                NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption : true
            ]
            let storeURL = documentsURL?.appendingPathComponent("SchemeModel.sqlite")
            do { try psc?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options) }
            catch{
                print("Error")
            }
            guard let callBack = self.callBack else { return }
            DispatchQueue.main.async {
                callBack()
            }
        }
        
    }
    
    func save() {
        guard mainContext.hasChanges || writerContext.hasChanges else { return }
        mainContext.performAndWait {
            do {
                try self.mainContext.save()
            }
            catch { print("Error") }
            self.writerContext.performAndWait({
                do {
                    try self.writerContext.save()
                }
                catch { print("Error") }
            })
        }
        
    }
}
