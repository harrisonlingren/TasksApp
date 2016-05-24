//
//  EditViewController.swift
//  tasks
//
//  Created by Lingren, Harrison on 5/19/16.
//  Copyright © 2016 apps.lingren.co. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    //var taskToEdit:NSManagedObject!
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var notesText: UITextView!
    
    var titleString:String!
    var notesString:String!
    var editMode:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleText.text = titleString
        notesText.text = notesString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "unwindFromSaveEdit" {
            print("EditVC: Unwinding from save action")
            
            if let _ = segue.destinationViewController as? TableView { print("EditVC: Saving item to table...") }
            else { print("EditVC: Could not update item") }
            
        } else if segue.identifier! == "unwindFromCancelEdit" {
            print("EditVC: Item edit action cancelled")
            
        } else {
            print("EditVC: No segue by identifier \(segue.identifier) was found")
            
        }
    }
}