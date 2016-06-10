//
//  TableView.swift
//  tasks
//
//  Created by Lingren, Harrison on 5/19/16.
//  Copyright © 2016 apps.lingren.co. All rights reserved.
//

import UIKit
import Firebase

class TableView: UITableViewController {

    //var taskSent:NSManagedObject!
    var ref = FIRDatabase.database().reference()
    private var _refHandle: FIRDatabaseHandle!
    var indexToBeEdited:NSIndexPath!
    
    @IBOutlet var clientTable:UITableView!
    
    var taskList: [FIRDataSnapshot]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.clientTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "taskCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.taskList.removeAll()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("tasks").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            self.taskList.append(snapshot)
            self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.taskList.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
        
        // Listen for deleted messages in the Firebase database
        _refHandle = self.ref.child("tasks").observeEventType(.ChildRemoved, withBlock: { (snapshot) -> Void in
            self.taskList.removeAll()
            self.taskList.append(snapshot)
            self.clientTable.deleteRowsAtIndexPaths([self.indexToBeEdited], withRowAnimation: .Fade)
        })
        
        // Listen for updated messages in the Firebase database
        _refHandle = self.ref.child("tasks").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            self.taskList.removeAll()
            self.taskList.append(snapshot)
            //self.clientTable.deleteRowsAtIndexPaths([self.indexToBeEdited], withRowAnimation: .Fade)
            //self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.taskList.count-1, inSection: 0)], withRowAnimation: .Automatic)
            self.clientTable.reloadRowsAtIndexPaths([self.indexToBeEdited], withRowAnimation: .Fade)
        })
        
        print("New count: ", self.taskList.count, "\n")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath)
        
        // Unpack message from Firebase DataSnapshot
        let taskSnapshot:FIRDataSnapshot! = self.taskList[indexPath.row]
        
        print("Task title:", (taskSnapshot.value as! Dictionary<String, String>)["title"]!)
        print("Task notes:", (taskSnapshot.value as! Dictionary<String, String>)["notes"]!)
        
        let task = taskSnapshot.value as! Dictionary<String, String>
        let title = task["title"] as String!
        let notes = task["notes"] as String!
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = notes
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // REMOVE DATA FROM FIREBASE
            
            let keySnapshot:FIRDataSnapshot! = self.taskList[indexPath.row]
            let keyValueDict = keySnapshot.value as! Dictionary<String, String>
            let keyValue = keyValueDict["key"]
            let path = "tasks/" + keyValue!
            
            self.ref.child(path).removeValue()
            
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            indexToBeEdited = indexPath
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    func getData(title:String, notes:String?, key:String) -> [String: String] {
        var notesText:String
        if let notesTemp:String = notes {
            notesText = notesTemp
        } else { notesText = "" }
        let data = [
            "title": title,
            "notes": notesText,
            "key": key
        ]
        return data
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexToBeEdited = indexPath
        editItem(self.tableView.cellForRowAtIndexPath(indexPath))
    }
    
    // Connect this to the Add button
    @IBAction func addItem(sender:AnyObject?) {
        // Declare an Alert controller
        let alert = UIAlertController(title: "New Task", message: "Add New Task", preferredStyle: .Alert)
        
        // Define the save alert action
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            (action:UIAlertAction) -> Void in
            
            // Declare all text fields for entering data
            let titleField = alert.textFields![0]
            let notesField = alert.textFields![1]
            
            // Save the data
            self.saveData(titleField.text!, notesText: notesField.text!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (action:UIAlertAction) -> Void in
        })
        
        // Text fields and placeholders
        alert.addTextFieldWithConfigurationHandler {(textField:UITextField!) -> Void in textField.placeholder = "Task"}
        alert.addTextFieldWithConfigurationHandler {(textField:UITextField!) -> Void in textField.placeholder = "Notes"}
        
        // Add actions
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Connect this to the Add button
    func editItem(sender:AnyObject?) {
        // Declare an Alert controller
        let alert = UIAlertController(title: "Edit Task", message: "Edit Task", preferredStyle: .Alert)
        
        // Define the save alert action
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            (action:UIAlertAction) -> Void in
            
            // Declare all text fields for entering data
            let titleField = alert.textFields![0]
            let notesField = alert.textFields![1]
            
            // Save the data
            
            let keySnapshot:FIRDataSnapshot! = self.taskList[self.indexToBeEdited.row]
            let keyValueDict = keySnapshot.value as! Dictionary<String, String>
            let keyValue = keyValueDict["key"]
            
            self.updateData(titleField.text!, notesText: notesField.text!, key:keyValue!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (action:UIAlertAction) -> Void in
        })
        
        let selectedIndex = self.tableView.indexPathForSelectedRow
        let cell = self.tableView.cellForRowAtIndexPath(selectedIndex!)!
        
        let oldTitle = cell.textLabel!.text
        /*var oldNotes = ""
        
        if let oldNotesTemp = cell.detailTextLabel!.text as String? {
            oldNotes = oldNotesTemp
        } else {
            oldNotes = "Notes"
        }*/
        
        let oldNotes = "Notes"
        
        // Text fields and placeholders
        alert.addTextFieldWithConfigurationHandler {(textField:UITextField!) -> Void in textField.placeholder = oldTitle}
        alert.addTextFieldWithConfigurationHandler {(textField:UITextField!) -> Void in textField.placeholder = oldNotes}
        
        // Add actions
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    func saveData(titleText:String, notesText:String?) {
        let newKey = self.ref.child("tasks").childByAutoId().key as String
        let mdata = getData(titleText, notes:notesText, key:newKey)
        let path = "tasks/" + newKey
        ref.child(path).setValue(mdata)
    }
    
    func updateData(titleText:String, notesText:String?, key:String) {
        let mdata = getData(titleText, notes:notesText, key:key)
        let path = "tasks/" + key
        ref.child(path).updateChildValues(mdata)
        self.clientTable.reloadData()
    }
}
