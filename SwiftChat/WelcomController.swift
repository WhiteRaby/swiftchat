//
//  WelcomController.swift
//  SwiftChat
//
//  Created by Alexandr on 01.04.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class WelcomController: UIViewController {

    override func viewDidLoad() {
                
        let mainStoryboard = self.storyboard
        
        
        DataManager.sharedManager.authorization { (found, user) in
            if found {
                print("Found: \(user?.name)")
                DataManager.sharedManager.logIn(user!)
                let splitController = mainStoryboard?.instantiateViewControllerWithIdentifier("SplitController") as! SplitController
                
                let navDetailController = splitController.viewControllers.last as! UINavigationController
                let detailController = navDetailController.topViewController
                
                (detailController?.view.viewWithTag(99) as! UILabel).text =
                    "Hello, \(DataManager.sharedManager.userName!)"
                
                self.presentViewController(splitController, animated: true, completion: nil)
                
            } else {
                print("not Found")
                
                let vc = mainStoryboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
                vc.modalTransitionStyle = .CrossDissolve
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
}
