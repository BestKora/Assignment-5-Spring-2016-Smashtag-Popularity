//
//  Database.swift
//
//  Created by Tatiana Kornilova on 3/18/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

class MyDocument :UIManagedDocument {
    
    override class func persistentStoreName() -> String{
        return "Twitter.sqlite"
    }
 
    override func contentsForType(typeName: String) throws -> AnyObject {
        print ("Auto-Saving Document")
        return try! super.contentsForType(typeName)
    }
    
    override func handleError(error: NSError, userInteractionPermitted: Bool) {
        // идея отсюда http://blog.stevex.net/2011/12/uimanageddocument-autosave-troubleshooting/
        print("Ошибка при записи:\(error.localizedDescription)")
        if let userInfo = error.userInfo as? [String:AnyObject],
            let conflicts = userInfo["conflictList"] as? NSArray{
            print("Конфликты при записи:\(conflicts)")
            
        }
    }
}

extension NSManagedObjectContext
{
    public func saveThrows () {
        do {
            try save()
        } catch let error  {
            print("Core Data Error: \(error)")
        }
    }
}

extension UIManagedDocument
{
    class func useDocument (completion: ( document: MyDocument) -> Void) {
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                                   inDomains: .UserDomainMask)
        let url = urls[urls.count-1].URLByAppendingPathComponent(doc)
       // print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
            [ NSMigratePersistentStoresAutomaticallyOption: true,
              NSInferMappingModelAutomaticallyOption: true]
        
        document.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if let parentContext = document.managedObjectContext.parentContext{
            parentContext.performBlock {
                parentContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        
        if !fileManager.fileExistsAtPath(url.path!) {
            document.saveToURL(url, forSaveOperation: .ForCreating) { (success) -> Void in
                if success {
                  //  print("File создан: Success")
                    completion (document: document)
                }
            }
        }else  {
            if document.documentState == .Closed {
                document.openWithCompletionHandler(){(success:Bool) -> Void in
                    if success {
                     //   print("File существует: Открыт")
                        completion (document: document)                    }
                }
            } else {
                completion ( document: document)
            }
        }
    }
}


//NSMergeByPropertyStoreTrumpMergePolicy

