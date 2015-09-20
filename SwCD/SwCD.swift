//
//  SwCD.swift
//  SwCD
//
//  Created by xxxAIRINxxx on 2015/05/01.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import CoreData

public typealias SaveCompletionHandler = (Bool, NSError?) -> Void

public class SwCD {
    
    // MARK: - Public
    
    public class func setup(modelName: String, dbRootDirPath: NSSearchPathDirectory?, dbDirName: String?, dbName: String?) {
        SwCD.sharedInstance.modelName = modelName
        
        if let _dbRootDirPath = dbRootDirPath {
            SwCD.sharedInstance.dbRootDirPath = NSSearchPathForDirectoriesInDomains(_dbRootDirPath, .UserDomainMask, true)[0] 
        }
        
        if let _dbDirName = dbDirName {
            SwCD.sharedInstance.dbDirName = _dbDirName
        }
        
        if let _dbName = dbName {
            SwCD.sharedInstance.dbName = _dbName
        }
    }
    
    // MARK: - Private
    
    private static var sharedInstance = SwCD()
    
    private static let ManagedObjectContextKey : String = "SwCDManagedObjectContextKey"
    
    private var modelName : String?
    private var dbRootDirPath : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
    private var dbDirName : String = "SwCD"
    private var dbName : String = "SwCDDB"
    
    private lazy var mainQueueContext : NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self.rootSaveingContext
        context.obtainPermanentIDsBeforeSaving()
        context.registerContextDidSaveNotification()
        return context
    }()
    
    private lazy var rootSaveingContext : NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.performBlock({
            context.persistentStoreCoordinator = self.defaultCoordinator
        })
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    private lazy var defaultCoordinator : NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.defaultManagedObjectModel)
        
        var error: NSError?
        let store: NSPersistentStore?
        do {
            store = try coordinator.addPersistentStoreWithType(
                        NSSQLiteStoreType,
                        configuration: nil,
                        URL: self.storeURL(),
                        options: nil)
        } catch var error1 as NSError {
            error = error1
            store = nil
        } catch {
            fatalError()
        }
        
        if let _error = error {
            // re create
            let isMigrationError = (_error.code == NSPersistentStoreIncompatibleVersionHashError) || (_error.code == NSMigrationMissingSourceModelError)
            if _error.domain == NSCocoaErrorDomain && isMigrationError == true {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(self.storeURL())
                } catch _ {
                }
                var reError: NSError?
                let reStore: NSPersistentStore?
                do {
                    reStore = try coordinator.addPersistentStoreWithType(
                                        NSSQLiteStoreType,
                                        configuration: nil,
                                        URL: self.storeURL(),
                                        options: nil)
                } catch var error as NSError {
                    reError = error
                    reStore = nil
                } catch {
                    fatalError()
                }
                if reStore == nil {
                    print("create persistentStores error : " + reError!.localizedDescription)
                    abort()
                }
            }
        }
        
        let persistentStores = coordinator.persistentStores
        if persistentStores.count > 0 && self.defaultPersistentStore == nil {
            self.defaultPersistentStore = persistentStores[0]
        }
        
        return coordinator
    }()
    
    private lazy var defaultManagedObjectModel : NSManagedObjectModel = {
        if self.modelName == nil {
            assert(true, "need set model name")
        }
        
        
        var modelURL = NSBundle.mainBundle().URLForResource(self.modelName!, withExtension: "momd")
        // need unit test
        if modelURL == nil {
           modelURL = NSBundle(forClass: SwCD.self).URLForResource(self.modelName!, withExtension: "momd")
        }
        var model = NSManagedObjectModel(contentsOfURL: modelURL!)
        return model!
    }()
    
    private var defaultPersistentStore : NSPersistentStore?
    
    // MARK: - FilePath
    
    private func storeURL() -> NSURL {
        let dirPath = self.dbRootDirPath + "/" + self.dbDirName
        self.createDirectoryIfNeeded(dirPath)
        let filePath = (dirPath as NSString).stringByAppendingPathComponent(self.dbName + ".sqlite")
        return NSURL(fileURLWithPath: filePath)
    }
    
    private func createDirectoryIfNeeded(path: String) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(path) == false {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path,
                                withIntermediateDirectories: true,
                                attributes: nil)
                return true
            } catch _ {
                return false
            }
        } else {
            return true
        }
    }
}

// MARK: - NSManagedObjectContext Extensions

public extension NSManagedObjectContext {
    
    class func mainQueueContext() -> NSManagedObjectContext {
        return SwCD.sharedInstance.mainQueueContext
    }
    
    class func rootSaveingContext() -> NSManagedObjectContext {
        return SwCD.sharedInstance.rootSaveingContext
    }
    
    class func contextWithParent(parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = parentContext
        
        return context
    }
    
    class func contextForCurrentThread() -> NSManagedObjectContext {
        if NSThread.isMainThread() == true {
            return NSManagedObjectContext.mainQueueContext()
        } else {
            let threads = NSThread.currentThread().threadDictionary
            var threadContext = threads[SwCD.ManagedObjectContextKey] as! NSManagedObjectContext?
            if threadContext == nil {
                threadContext = NSManagedObjectContext.contextWithParent(NSManagedObjectContext.rootSaveingContext())
                threads[SwCD.ManagedObjectContextKey] = threadContext
            }
            return threadContext!
        }
    }
    
    // MARK: - Notification
    
    func registerContextDidSaveNotification() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contextWillSave:",
            name: NSManagedObjectContextDidSaveNotification,
            object: self)
    }
    
    func obtainPermanentIDsBeforeSaving() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contextWillSave:",
            name: NSManagedObjectContextWillSaveNotification,
            object: NSManagedObjectContext.rootSaveingContext())
    }
    
    func rootContextChanged(notification: NSNotification) {
        if let _context = notification.object as? NSManagedObjectContext {
            if _context != NSManagedObjectContext.rootSaveingContext() {
                return
            }
            
            if NSThread.isMainThread() == false {
                dispatch_async(dispatch_get_main_queue(), {
                    self.rootContextChanged(notification)
                })
            } else {
                NSManagedObjectContext.mainQueueContext().mergeChangesFromContextDidSaveNotification(notification)
            }
        }
    }
    
    func contextWillSave(notification: NSNotification) {
        let context = notification.object as! NSManagedObjectContext
        let insertedObjects = context.insertedObjects as NSSet
        
        if insertedObjects.count > 0 {
            var error: NSError?
            let success: Bool
            do {
                try context.obtainPermanentIDsForObjects(insertedObjects.map(){($0 as! NSManagedObject)})
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            
            if success == false {
                assert(true, "contextWillSave error : " + error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Save
    
    class func saveWithBlockAndWait(block: (NSManagedObjectContext -> Void)?, completion: SaveCompletionHandler?) {
        let localContext = NSManagedObjectContext.contextForCurrentThread()
        localContext.performBlockAndWait({
            block?(localContext)
            localContext.saveAndCompletion(completion)
        })
    }
    
    func saveAndCompletion(completion: SaveCompletionHandler?) {
        if self.hasChanges == false {
            print("SwCD Save : No Changes")
            dispatch_async(dispatch_get_main_queue(), {
                completion?(false, nil)
            })
            return
        }
        
        let saveBlock: Void -> Void = {
            var error: NSError?
            
            let success: Bool
            do {
                try self.save()
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            } catch {
                fatalError()
            }
            
            if success == true {
                if let _parentContext = self.parentContext {
                    _parentContext.saveAndCompletion(completion)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion?(true, nil)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion?(false, error)
                })
            }
        }
        
        self.performBlockAndWait(saveBlock)
    }
}

// MARK: - NSPersistentStoreCoordinator Extensions

public extension NSPersistentStoreCoordinator {
    func defaultCoordinator() -> NSPersistentStoreCoordinator {
        return SwCD.sharedInstance.defaultCoordinator
    }
}

// MARK: - NSManagedObject Extensions

// @see : http://stackoverflow.com/questions/24537238/swift-return-array-of-type-self

public protocol NamedManagedObject {
    static func entityName() -> String
}

extension NSManagedObject : NamedManagedObject {
    public class func entityName() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName(), inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}

// MARK: - SwCD Extensions

public extension SwCD {
    
    class func createFetchRequest<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, context: NSManagedObjectContext) -> NSFetchRequest {
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName(entityType.entityName(), inManagedObjectContext: context)
        
        return request
    }
    
    class func createEntity<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type) -> T {
        let context = NSManagedObjectContext.contextForCurrentThread()
        let description = NSEntityDescription.entityForName(entityType.entityName(), inManagedObjectContext: context)!
        let entity = entityType.init(entity: description, insertIntoManagedObjectContext: context)
        
        return entity
    }
    
    class func executeFetch<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, request: NSFetchRequest, inContext: NSManagedObjectContext) -> [T] {
        var result: [T] = []
        
        if request.entityName != entityType.entityName() {
            return result
        }
        
        inContext.performBlockAndWait({
            let results: [AnyObject]?
            do {
                results = try inContext.executeFetchRequest(request)
            } catch {
                fatalError()
            }
            if results != nil {
                result = results as! [T]
            }
        })

        return result
    }
    
    class func all<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        let context = NSManagedObjectContext.contextForCurrentThread()
        let request = self.createFetchRequest(entityType, context: context)
        if let _sortDescriptors = sortDescriptors {
            request.sortDescriptors = _sortDescriptors
        }
        
        return self.executeFetch(entityType, request: request, inContext: context)
    }
    
    class func find<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, fetchLimit: Int?) -> [T] {
        let context = NSManagedObjectContext.contextForCurrentThread()
        let request = self.createFetchRequest(entityType, context: context)
        
        if let _predicate = predicate {
            request.predicate = _predicate
        }
        
        if let _sortDescriptors = sortDescriptors {
            request.sortDescriptors = _sortDescriptors
        }
        
        if let _fetchLimit = fetchLimit {
            request.fetchLimit = _fetchLimit
        }
        
        return self.executeFetch(entityType, request: request, inContext: context)
    }
    
    class func findFirst<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, predicate: NSPredicate?) -> T? {
        let result = self.find(entityType, predicate: predicate, sortDescriptors: nil, fetchLimit: 1)
        
        if result.count > 0 {
            return result.first
        }
        return nil
    }
    
    class func insert<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, entities: [T], completion: SaveCompletionHandler?) {
        NSManagedObjectContext.saveWithBlockAndWait({context in
            for entityObj in entities {
                entityObj.managedObjectContext?.insertObject(entityObj)
            }
            },
            completion: completion)
    }
    
    class func update<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, entities: [T], completion: SaveCompletionHandler?) {
        NSManagedObjectContext.saveWithBlockAndWait({context in
            for entityObj in entities {
                do {
                    try entityObj.managedObjectContext?.save()
                } catch {
                    fatalError()
                }
            }
            },
            completion: completion)
    }
    
    class func delete<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, entities: [T], completion: SaveCompletionHandler?) {
        NSManagedObjectContext.saveWithBlockAndWait({context in
            for entityObj in entities {
                entityObj.managedObjectContext?.deleteObject(entityObj)
            }
            },
            completion: completion)
    }
    
    class func deleteAll<T: NSManagedObject where T: NamedManagedObject>(entityType: T.Type, completion: SaveCompletionHandler?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        let request = self.createFetchRequest(entityType, context: context)
        
        let result = self.executeFetch(entityType, request: request, inContext: context)
        
        NSManagedObjectContext.saveWithBlockAndWait({saveContext in
            for entityObj in result {
                entityObj.managedObjectContext?.deleteObject(entityObj)
            }
            },
            completion: completion)
    }
    
    class func save(block: (NSManagedObjectContext -> Void)?, completion: SaveCompletionHandler?) {
        NSManagedObjectContext.saveWithBlockAndWait({context in
            block?(context)
            },
            completion: completion)
    }
}
