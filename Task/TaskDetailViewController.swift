//
//  TaskDetailViewController.swift
//  Task
//
//  Created by Pawan on 05/11/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskEditDelegate: class {
	func didFisishTaskEditing()
}

class TaskDetailViewController: UIViewController {
	// Outlets
	@IBOutlet weak var taskTextField: UITextField!
	@IBOutlet weak var innerView: UIView!
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var lblTitle: UILabel!
	
	// Variable
	fileprivate let realm = try! Realm()
	weak var delegate:TaskEditDelegate?
	open var sharedTask:Task?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Update title
		if let task = sharedTask {
			lblTitle.text = "Update Task"
			taskTextField.text = task.name
		} else {
			lblTitle.text = "Add New Task"
		}
		
		// Update UI
		innerView.addDropShadow()
		topView.addDropShadow()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Text field become active
		taskTextField.becomeFirstResponder()
	}
	
	// MARK: Cancel action
	@IBAction func cancelTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: Edit or create new task
	@IBAction func saveTaskTapped(_ sender: Any) {
		// Check text field 
		guard let editedText = taskTextField.text else {
			return
		}
		
		// Show alert if nothing entered
		if editedText.count == 0 {
			showAlert()
			return
		}
		
		// Edit shared task
		if let task = sharedTask {
			try! realm.write {
				task.name = editedText
				task.createdAt = NSDate()
				task.isCompleted = false
			}
			
		} else { // New task
			try! realm.write {
				let newTask = Task()
				newTask.name = editedText
				newTask.createdAt = NSDate()
				realm.add(newTask)
			}
		}
		
		// Go back to previous
		self.delegate?.didFisishTaskEditing()
		dismiss(animated: true, completion: nil)
	}
	
	fileprivate func showAlert() {
		let alert = UIAlertController(title: "Error",
		                              message: "Please enter task name",
		                              preferredStyle: UIAlertController.Style.alert)
		
		let cancelAction = UIAlertAction(title: "Ok",
		                                 style: .cancel, handler: nil)
		
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: Text field delegate
extension TaskDetailViewController : UITextFieldDelegate {
	
	// Limit characters
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		return newLength <= 30
	}
	
}


