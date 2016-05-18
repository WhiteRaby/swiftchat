//
//  LoginController.swift
//  SwiftChat
//
//  Created by Alexandr on 30.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    @IBOutlet weak var backgroundView: UIImageView!
    var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = self.view.frame
//        visualEffectView.frame.origin = CGPointZero
//        visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        visualEffectView.alpha = 0
//        visualEffectView.hidden = true
//        view.insertSubview(visualEffectView, aboveSubview: backgroundView)
//        view.addSubview(visualEffectView)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(LoginController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(LoginController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        topConstraint.constant = CGRectGetMidY(view.frame) - 152
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let frame = ((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue())!
        
        UIView.animateWithDuration(0.3) { 
            self.topConstraint.constant = (self.view.frame.size.height - frame.size.height) / 2 - 152
            self.view.layoutIfNeeded()
            
            //self.visualEffectView.effect = UIBlurEffect(style: .Dark)
            //self.backgroundView.alpha = 0.85
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        //let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        
        UIView.animateWithDuration(0.3) {
            self.topConstraint.constant = CGRectGetMidY(self.view.frame) - 152
            self.view.layoutIfNeeded()
            
            //self.visualEffectView.effect = nil
            //self.backgroundView.alpha = 1
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
        case nickNameTextField:
            firstNameTextField.becomeFirstResponder()
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            lastNameTextField.resignFirstResponder()
        default:
            print("default section")
        }
        return true
    }
    
    @IBAction func signupButtonClickAction(sender: AnyObject) {
        
        if nickNameTextField.text == "" {
            return
        }
        
        let user = User(name: nickNameTextField.text,
                        id: DataManager.sharedManager.deviceID(),
                        isOnline: true)
        
        DataManager.sharedManager.createUser(user)
        DataManager.sharedManager.logIn(user)
        self.performSegueWithIdentifier("LoginToSplit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let splitController = segue.destinationViewController as! UISplitViewController
        let navDetailController = splitController.viewControllers.last as! UINavigationController
        let detailController = navDetailController.topViewController

        (detailController?.view.viewWithTag(99) as! UILabel).text =
            "Hello, \(DataManager.sharedManager.userName!)"
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if UIDevice.currentDevice().model == "iPhone" {
            return UIInterfaceOrientationMask.Portrait
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
}
