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
	fileprivate let realm = try! Realm()
	fileprivate var toDoTasks = try! Realm().objects(Task.self).sorted(byKeyPath: "name", ascending: true)
	fileprivate var searchResults = try! Realm().objects(Task.self)
	
	//
	var searchController: UISearchController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Search result controller
		let searchResultsController = UITableViewController(style: .plain)
		searchResultsController.tableView.delegate = self
		searchResultsController.tableView.dataSource = self
		searchResultsController.tableView.rowHeight = 60
		searchResultsController.tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
		
		// Search controller
		searchController = UISearchController(searchResultsController: searchResultsController)
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search task"
		tableView.tableHeaderView?.addSubview(searchController.searchBar)
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
	
	// MARK: Segment Action
	@IBAction func scopeChanged(_ sender: Any) {
		//
		let scopeBar = sender as! UISegmentedControl
		
		switch scopeBar.selectedSegmentIndex {
		case 0:
			toDoTasks = toDoTasks.sorted(byKeyPath: "name", ascending: true)
		case 1:
			toDoTasks = toDoTasks.sorted(byKeyPath: "createdAt", ascending: false)
		default:
			toDoTasks = toDoTasks.sorted(byKeyPath: "name", ascending: true)
		}
		tableView.reloadData()
	}
	
	func filterResultsWithSearchString(searchString: String) {
		let predicate = NSPredicate(format: "name BEGINSWITH [c]%@", searchString)
		let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
		
		switch scopeIndex {
		case 0:
			searchResults = toDoTasks.filter(predicate).sorted(byKeyPath: "name", ascending: true)
		case 1:
			searchResults = toDoTasks.filter(predicate).sorted(byKeyPath: "created", ascending: false)
		default:
			searchResults = toDoTasks.filter(predicate)
		}
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

// MARK: Table view datasource
extension TaskViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchController.isActive ? searchResults.count : toDoTasks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let taskCell = self.tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell") as! TaskTableViewCell
		
		// Update UI
		let task  = searchController.isActive ? searchResults[indexPath.row] : toDoTasks[indexPath.row]
		taskCell.lblTitle.attributedText = self.attributedText(actualText: task.name, shouldStrikeThrough: task.isCompleted)
		taskCell.lblTitle.textColor =  task.isCompleted ? UIColor.lightGray : UIColor.black
		
		return taskCell
	}
}

//MARK: Table view delegate
extension TaskViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// Update task status
		if indexPath.row < toDoTasks.count {
			let task  = searchController.isActive ? searchResults[indexPath.row] : toDoTasks[indexPath.row]
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
			let task  = self.searchController.isActive ? self.searchResults[indexPath.row] : self.toDoTasks[indexPath.row]
			try! self.realm.write {
				self.realm.delete(task)
			}
			tableView.deleteRows(at: [indexPath], with: .top)
		}
		let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [unowned self] (editAction, indexPath) -> Void in
			
			// Edit Task
			let task  = self.searchController.isActive ? self.searchResults[indexPath.row] : self.toDoTasks[indexPath.row]
			self.updateTask(task: task)
			
		}
		return [deleteAction, editAction]
	}
}

// MARK: Search result
extension TaskViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		let searchString = searchController.searchBar.text!
		filterResultsWithSearchString(searchString: searchString)
		
		let searchResultsController = searchController.searchResultsController as! UITableViewController
		searchResultsController.tableView.reloadData()
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
			attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
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
