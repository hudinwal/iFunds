//
//  CoreDataStack.swift
//  iFunds
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation
import CoreData

typealias LargeOperationMOCCallbackBlock = ((NSManagedObjectContext?)->())
typealias InitCallbackBlock = (()->())

class CoreDataStack {
    var persistingContext : NSManagedObjectContext
    var mainContext : NSManagedObjectContext
    
    private var callBack : InitCallbackBlock?
    
    init?(callBack:InitCallbackBlock?) {
        self.callBack = callBack
        let modelURLOpt = Bundle.main.url(forResource: "SchemeModel", withExtension: "momd")
        guard let modelURL = modelURLOpt else { return nil }
        let modelOpt = NSManagedObjectModel(contentsOf: modelURL)
        guard let model = modelOpt else { return nil }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.persistingContext.persistentStoreCoordinator = psc
        self.mainContext.parent = self.persistingContext;
        
        DispatchQueue.global(qos: .background).async {
            let psc = self.persistingContext.persistentStoreCoordinator
            let defaultFileManager = FileManager.default
            let documentsURL = defaultFileManager.urls(for: .documentDirectory, in: .userDomainMask).last
            let options = [
                NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption : true
            ]
            let storeURL = documentsURL?.appendingPathComponent("SchemeModel.sqlite")
            do {
                try psc?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            }
            catch{
                print("Error")
            }
            guard let callBack = self.callBack else { return }
            DispatchQueue.main.async {
                callBack()
            }
        }
        
    }
    
    func createWriterContext() -> NSManagedObjectContext {
        let writerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        writerContext.parent = self.mainContext
        return writerContext
    }
    
    func newBatchOperationContext(callBack:@escaping LargeOperationMOCCallbackBlock) {
        let modelURLOpt = Bundle.main.url(forResource: "SchemeModel", withExtension: "momd")
        guard let modelURL = modelURLOpt else {
            DispatchQueue.main.async {
                callBack(nil)
            }
            return;
        }
        let modelOpt = NSManagedObjectModel(contentsOf: modelURL)
        guard let model = modelOpt else { callBack(nil); return }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let blockWriterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        blockWriterContext.persistentStoreCoordinator = psc
        DispatchQueue.global(qos: .background).async {
            let psc = blockWriterContext.persistentStoreCoordinator
            let defaultFileManager = FileManager.default
            let documentsURL = defaultFileManager.urls(for: .documentDirectory, in: .userDomainMask).last
            let options = [
                NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption : true
            ]
            let storeURL = documentsURL?.appendingPathComponent("SchemeModel.sqlite")
            do {
                try psc?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                DispatchQueue.main.async {
                    callBack(blockWriterContext)
                }
            }
            catch{
                print("Error")
                DispatchQueue.main.async {
                    callBack(nil)
                }
            }
        }
    }
    
    func save(writerContext: NSManagedObjectContext, saveUptoRoot: Bool = false) {
        guard writerContext.hasChanges else { return }
        writerContext.performAndWait { [weakSelf = self] in
            do {
                try writerContext.save()
            }
            catch { print("Error") }
            if saveUptoRoot {
                weakSelf.saveMainContext()
            }
        }
    }
    
    func saveMainContext() {
        guard mainContext.hasChanges || persistingContext.hasChanges else { return }
        mainContext.performAndWait { [weakSelf = self] in
            do {
                try weakSelf.mainContext.save()
            }
            catch { print("Error") }
            self.persistingContext.performAndWait({ [weakSelf = self] in
                do {
                    try weakSelf.persistingContext.save()
                }
                catch { print("Error") }
            })
        }
    }
    
    func savePersistingContext() {
        guard persistingContext.hasChanges else { return }
        persistingContext.performAndWait { [weakSelf = self] in
            do {
                try weakSelf.persistingContext.save()
            }
            catch { print("Error") }
        }
    }
}
