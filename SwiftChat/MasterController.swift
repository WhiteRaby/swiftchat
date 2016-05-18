//
//  MasterController.swift
//  SwiftChat
//
//  Created by Alexandr on 30.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class MasterController: UITableViewController {
    
    var users: Array<User> = []
    var selected: Int?
    
    override func viewDidLoad() {
        
        //selected = 0
        
        DataManager.sharedManager.observeUsers {
            DataManager.sharedManager.getUsers {
                self.users = $0
                for i in 0..<self.users.count {
                    if self.users[i].name == DataManager.sharedManager.userName! {
                        self.users.removeAtIndex(i)
                        break
                    }
                }
                
                self.tableView.reloadData()
                if let selected = self.selected {
                    self.tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: selected, inSection: 0),
                        animated: false,
                        scrollPosition: .None)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selected = selected {
            tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: selected, inSection: 0),
                                           animated: false,
                                           scrollPosition: .None)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MasterTableViewCell", forIndexPath: indexPath) as! MasterTableViewCell
        
        cell.nickName.text = users[indexPath.row].name
        if users[indexPath.row].isOnline == true {
            cell.status.image = UIImage.init(imageLiteral: "online")
        } else {
            cell.status.image = UIImage.init(imageLiteral: "offline")
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selected = indexPath.row
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MasterTableViewCell
        let name = cell.nickName.text
        
        let newDetailContriller = DetailController()
        newDetailContriller.senderId = DataManager.sharedManager.userName
        newDetailContriller.senderDisplayName = DataManager.sharedManager.userName
        newDetailContriller.recipientId = name
        
        splitViewController?.showDetailViewController(
            UINavigationController(rootViewController: newDetailContriller), sender: nil)
    }
    
}
