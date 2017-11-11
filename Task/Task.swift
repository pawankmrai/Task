//
//  Task.swift
//  Task
//
//  Created by Pawan on 04/11/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
	dynamic var name = ""
	dynamic var createdAt = NSDate()
	dynamic var isCompleted = false
    
    convenience init(name: String, createdAt: NSDate, isCompleted: Bool) {
        self.init()
        self.name = name
        self.createdAt = createdAt
        self.isCompleted =  isCompleted
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
    
    func update(name: String, createAt: NSDate, isCompleted: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.name = name
            self.createdAt = createAt
            self.isCompleted = isCompleted
        }
    }
    
    func delete() {
        let realm  = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
}

extension Task {
	public class func getMockData() -> List<Task> {
		let dummyTaskList = List<Task>()
		
		// 1
		let dummyTask1 = Task()
		dummyTask1.name = "Task1"
		dummyTaskList.append(dummyTask1)
		
		// 2
		let dummyTask2 = Task()
		dummyTask2.name = "Task2"
		dummyTaskList.append(dummyTask2)
		
		// 3
		let dummyTask3 = Task()
		dummyTask3.name = "Task3"
		dummyTaskList.append(dummyTask3)
		
		// 4
		let dummyTask4 = Task()
		dummyTask4.name = "Task4"
		dummyTaskList.append(dummyTask4)
		
		return dummyTaskList
	}
}
