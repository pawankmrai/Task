//
//  TaskTests.swift
//  TaskTests
//
//  Created by Pawan on 04/11/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import XCTest
@testable import Task
@testable import RealmSwift

class TaskTests: XCTestCase {
    fileprivate let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddObject() {
        // Static data
        let dateString  = "11-11-2017"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let date = dateFormatter.date(from: dateString) as NSDate?
        
        // Create task object
        let task = Task(name: "Get Grocery", createdAt: date!, isCompleted: false)
        task.save()
        
        // Get object from database
        let taskFromDatabase = realm.objects(Task.self).last
        
        // Except the task is same, which was saved
        XCTAssertTrue(task.name ==  taskFromDatabase?.name, "Task name should be same")
        XCTAssertTrue(task.isCompleted ==  taskFromDatabase?.isCompleted, "Task completion status should be same")
        XCTAssertTrue(task.createdAt ==  taskFromDatabase?.createdAt, "Task create date should be same")
    }
    
    func testUpdateObject() {
        
        // Static data
        let dateString  = "11-11-2017"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let date = dateFormatter.date(from: dateString) as NSDate?
        
        // Create task object
        let task = Task(name: "Get Grocery", createdAt: date!, isCompleted: false)
        task.save()
        
        // Update data
        let updatedName = "Get Grocery Done"
        let updateCreateAt = NSDate()
        let updateIsCompleted = true
        
        // Update in database
        task.update(name: updatedName, createAt: updateCreateAt, isCompleted: updateIsCompleted)
        
        // Get object from database
        let taskFromDatabase = realm.objects(Task.self).last
        
        // Except the task is same, which was saved
        XCTAssertTrue(taskFromDatabase?.name ==  updatedName, "Updated task name should be same")
        XCTAssertTrue(taskFromDatabase?.isCompleted == updateIsCompleted, "Updated task completion status should be same")
        XCTAssertTrue(taskFromDatabase?.createdAt == updateCreateAt, "Updated task create date should be same")
    }
    
    func testDeleteObject() {
        // Delete all objects from database
        let realm = try! Realm()
        let allTasks = realm.objects(Task.self)
        try! realm.write {
            realm.delete(allTasks)
        }
        
        // Create 3 task object
        //1
        let task1 = Task(name: "Task 1", createdAt: NSDate(), isCompleted: false)
        task1.save()
        
        // 2
        let task2 = Task(name: "Task 2", createdAt: NSDate(), isCompleted: false)
        task2.save()
        
        // 3
        let task3 = Task(name: "Task 3", createdAt: NSDate(), isCompleted: false)
        task3.save()
        
        // Check task oject in database
        
        let lastTask = realm.objects(Task.self).last
        lastTask?.delete()
        
        // Check the count in database
        let tasks = realm.objects(Task.self)
        
        // Expect task count in database is 2
        XCTAssertTrue(tasks.count == 2, "Excepted tasks in database should be 2")
    }
}

