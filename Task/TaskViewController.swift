//
//  ViewController.swift
//  Task
//
//  Created by Pawan on 04/11/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import RealmSwift

class TaskViewController: UITableViewController {
	//
	fileprivate var toDoTasks: Results<Task> {
		get {
			let sorted = try! Realm().objects(Task.self).sorted(byKeyPath: "createdAt", ascending: true)
			return sorted
		}
	}
	fileprivate var filteredToDoTasks:Results<Task>?
	fileprivate let realm = try! Realm()
	let searchController = UISearchController(searchResultsController: nil)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add search controller
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search task"
		if #available(iOS 11, *) {
			
		} else {
			tableView.tableHeaderView = searchController.searchBar
		}
		definesPresentationContext = true
	}
	
	// MARK: Add new task
	@IBAction func addNewTaskTapped(_ sender: Any) {
		self.performSegue(withIdentifier: "showTaskDetail", sender: sender)
	}
	
	fileprivate func updateTask(task: Task) {
		// Update task details
		self.performSegue(withIdentifier: "showTaskDetail", sender: task)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: Table view datasource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return toDoTasks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
		
		// Update UI
		let task  = toDoTasks[indexPath.row]
		taskCell.lblTitle.attributedText = self.attributedText(actualText: task.name, shouldStrikeThrough: task.isCompleted)
		taskCell.lblTitle.textColor =  task.isCompleted ? UIColor.lightGray : UIColor.black
		
		return taskCell
	}
	
	//MARK: Table view delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// Update task status
		if indexPath.row < toDoTasks.count {
			let task  = toDoTasks[indexPath.row]
			try! realm.write {
				task.isCompleted = !task.isCompleted
			}
		}
		//
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (deleteAction, indexPath) -> Void in
			//Deletion task
			let task  = self.toDoTasks[indexPath.row]
			try! self.realm.write {
				self.realm.delete(task)
			}
			tableView.deleteRows(at: [indexPath], with: .top)
		}
		let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [unowned self] (editAction, indexPath) -> Void in
			
			// Edit Task
			let task  = self.toDoTasks[indexPath.row]
			self.updateTask(task: task)
			
		}
		return [deleteAction, editAction]
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showTaskDetail" {
			// Check if task edit task
			let taskDetailController = segue.destination as? TaskDetailViewController
			taskDetailController?.delegate = self
			if let task = sender as? Task {
				taskDetailController?.sharedTask = task
			}
		}
	}
}
// MARK: Search result
extension TaskViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		// TODO
	}
}

// Task edit delegate
extension TaskViewController: TaskEditDelegate {
	func didFisishTaskEditing() {
		self.tableView.reloadData()
	}
}

// MARK: Helper
extension TaskViewController {
	//
	open func attributedText(actualText: String, shouldStrikeThrough:Bool) -> NSMutableAttributedString {
		//
		let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: actualText)
		//
		if shouldStrikeThrough {
			attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
		}
		return attributeString
	}
}

// MARK: View helper
extension UIView {
	//
	func addDropShadow() {
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.5
		self.layer.shadowOffset = CGSize(width: 0, height: 2)
		self.layer.shadowRadius = 1
		self.layer.shouldRasterize = true
	}
}
