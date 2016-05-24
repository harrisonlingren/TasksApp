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
    var globalCount:Int = 0
    
    @IBOutlet var clientTable: UITableView!
    
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
            self.globalCount = self.taskList.count
            self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.taskList.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
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
        let taskSnapshot: FIRDataSnapshot! = self.taskList[indexPath.row]
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
            
            // Delete from manager, data entity !!!!!
            // dm.delete(indexPath)
            //dm.storedObjects.removeAtIndex(indexPath.row)
            
            // REMOVE DATA FROM FIREBASE
            
            let valueKey = self.ref.child("tasks/"(tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!).key
            
            
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    func sendMessage(data: [String: String]) {
        let mdata = data
        // Push data to Firebase Database
        let dataKey = self.ref.child("tasks").childByAutoId().key
        self.ref.child("tasks/\(dataKey)").setValue(mdata)
    }
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        
        if segue.identifier == "segueToEdit" {
            if let editVC = segue.destinationViewController as? EditViewController {
                print("TableVC: Showing details on EditView \(editVC.title)")
                
                let index = tableView.indexPathForSelectedRow?.row
                /*let task = dm.storedObjects[index!] as NSManagedObject
                
                for item in dm.storedObjects as [NSManagedObject] {
                    let itemText = item.valueForKey("title") as! String?
                    print("index: \(Int((dm.storedObjects.indexOf(item)?.value)!)), item: \(itemText!)")
                }

                
                if let taskTitle = task.valueForKey("title") as! String? {
                    editVC.titleString = taskTitle
                } else {
                    editVC.titleText.text = "No title found"
                }
                
                if let taskNotes = task.valueForKey("notes") as! String? {
                    editVC.notesString = taskNotes
                    
                } else {
                    editVC.notesText.text = "No notes found"
                }
                
                editVC.taskToEdit = task
                editVC.editMode = "edit" */
                
                
                // Code for edit window here...

            }
        } else if segue.identifier == "segueToAdd" {
            if let addVC = segue.destinationViewController as? EditViewController {
                print("TableVC: Segue to add item")
                addVC.editMode = "add"
            }
        } else { print("TableVC: No view found for \(segue.identifier).") }
    }
    
    
    func getData(title:String, notes:String?) -> [String: String] {
        var notesText:String
        if let notesTemp:String = notes {
            notesText = notesTemp
        } else { notesText = "" }
        let data = [
            "title": title,
            "notes": notesText
        ]
        return data
    }
    
    @IBAction func unwindFromCancelEdit(segue: UIStoryboardSegue) {
        print("TableVC: Unwinding from cancel action")
    }
    
    @IBAction func unwindFromSaveEdit(segue: UIStoryboardSegue) {
        print("TableVC: Saving item to table...")
        if let vc = segue.sourceViewController as? EditViewController {
            if vc.editMode == "add" {
                //dm.insert(vc.titleText.text!, notes: vc.notesText.text!, entityName: "Task")
                
                // Code for add child here...
                var mdata = getData(vc.titleText!.text!, notes:vc.notesText!.text)
                ref.child("tasks").childByAutoId().setValue(mdata)
                
                //globalCount++
            } else if vc.editMode == "edit" {
                //dm.update(vc.taskToEdit, title: vc.titleText.text!, notes: vc.notesText.text!)
                
                // Code for update child here...
                
            }
        }
        self.tableView.reloadData()
    }
}
