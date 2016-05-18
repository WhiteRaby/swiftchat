//
//  SplitController.swift
//  SwiftChat
//
//  Created by Alexandr on 30.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class SplitController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
}
