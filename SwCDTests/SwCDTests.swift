//
//  SwCDTests.swift
//  SwCDTests
//
//  Created by xxxAIRINxxx on 2015/05/01.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class SwCDTests: XCTestCase {
    
    var onceToken : dispatch_once_t = 0
    
    override func setUp() {
        super.setUp()
        
        dispatch_once(&onceToken) {
            SwCD.setup("TestModel", dbRootDirPath: nil, dbDirName: "Test", dbName: nil)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        SwCD.deleteAll(TestItem.self, completion: nil)
    }
    
    func testall() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        SwCD.insert(TestItem.self, entities: [self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 1, "")
        
        SwCD.insert(TestItem.self, entities: [self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 2, "")
        
        SwCD.deleteAll(TestItem.self, completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
    }
    
    func testExecuteFetch() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        let entity = self.dynamicType.createTestItem()
        entity.name = "test"
        SwCD.insert(TestItem.self, entities: [entity], completion: nil)
        
        let context = NSManagedObjectContext.contextForCurrentThread()
        let request = SwCD.createFetchRequest(TestItem.self, context: context)
        request.predicate = NSPredicate(format: "name == %@", argumentArray: ["test"])
        let results = SwCD.executeFetch(TestItem.self, request: request, inContext: context)
        
        XCTAssert(results.count == 1, "")
        let result = results[0]
        XCTAssert(result.name == "test", "")
        
        SwCD.deleteAll(TestItem.self, completion: nil)
    }
    
    func testFind() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        let entity = self.dynamicType.createTestItem()
        entity.name = "test"
        entity.identifier = "1"
        SwCD.insert(TestItem.self, entities: [entity], completion: nil)
        
        let entity2 = self.dynamicType.createTestItem()
        entity2.name = "test"
        entity2.identifier = "1"
        SwCD.insert(TestItem.self, entities: [entity2], completion: nil)
        
        let entity3 = self.dynamicType.createTestItem()
        entity3.name = "dummy"
        entity3.identifier = "dummy"
        SwCD.insert(TestItem.self, entities: [entity3], completion: nil)
        
        let predicate = NSPredicate(format: "name == %@", argumentArray: ["test"])
        let results = SwCD.find(TestItem.self, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)
        XCTAssert(results.count == 2, "")
        for en in results {
            XCTAssert(en.identifier == "1", "")
        }
    }
    
    func testFindFirst() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        let entity = self.dynamicType.createTestItem()
        entity.name = "test"
        entity.identifier = "1"
        SwCD.insert(TestItem.self, entities: [entity], completion: nil)
        
        let entity2 = self.dynamicType.createTestItem()
        entity2.name = "test"
        entity2.identifier = "2"
        SwCD.insert(TestItem.self, entities: [entity2], completion: nil)
        
        let entity3 = self.dynamicType.createTestItem()
        entity3.name = "dummy"
        entity3.identifier = "dummy"
        SwCD.insert(TestItem.self, entities: [entity3], completion: nil)
        
        let result = SwCD.findFirst(TestItem.self, predicate: NSPredicate(format: "identifier == %@", argumentArray: ["1"]))
        XCTAssert(result != nil, "")
        XCTAssert(result!.identifier == "1", "")
    }
    
    func testInsert() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        SwCD.insert(TestItem.self, entities: [self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 1, "")
        
        SwCD.insert(TestItem.self, entities: [self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 2, "")
        
        SwCD.insert(TestItem.self, entities: [
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 5, "")
    }
    
    func testUpdate() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        let entity = self.dynamicType.createTestItem()
        entity.name = "test"
        SwCD.insert(TestItem.self, entities: [entity], completion: nil)
        
        let before = SwCD.all(TestItem.self, sortDescriptors: nil)[0]
        XCTAssert(before.name == "test", "")
        
        entity.name = "testAfer"
        SwCD.update(TestItem.self, entities: [entity], completion: nil)
        
        let after = SwCD.all(TestItem.self, sortDescriptors: nil)[0]
        XCTAssert(after.name == "testAfer", "")
    }
    
    func testDelete() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        SwCD.insert(TestItem.self, entities: [
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem()], completion: nil)
        
        let entity = self.dynamicType.createTestItem()
        entity.name = "test"
        let identifier = entity.identifier
        SwCD.insert(TestItem.self, entities: [entity], completion: nil)
        
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 4, "")
        
        SwCD.delete(TestItem.self, entities: [entity], completion: nil)
        
        let entities = SwCD.all(TestItem.self, sortDescriptors: nil)
        XCTAssert(entities.count == 3, "")
        
        for en in entities {
            XCTAssert(en.identifier != identifier, "")
        }
    }
    
    func testDeleteAll() {
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
        
        SwCD.insert(TestItem.self, entities: [
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem(),
            self.dynamicType.createTestItem()], completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 3, "")
        
        SwCD.deleteAll(TestItem.self, completion: nil)
        XCTAssert(SwCD.all(TestItem.self, sortDescriptors: nil).count == 0, "")
    }
    
    class func createTestItem() -> TestItem {
        let entity =  SwCD.createEntity(TestItem.self)
        entity.identifier = NSUUID().UUIDString
        
        return entity
    }
}
