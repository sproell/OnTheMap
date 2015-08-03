//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/10/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var paddingView = UIView(frame: CGRectMake(0, 0, 15, self.tfUserName.frame.height))
        tfUserName.leftView = paddingView
        tfUserName.leftViewMode = UITextFieldViewMode.Always
        
        paddingView = UIView(frame: CGRectMake(0, 0, 15, self.tfPassword.frame.height))
        tfPassword.leftView = paddingView
        tfPassword.leftViewMode = UITextFieldViewMode.Always
    }
    
    @IBAction func login(sender: AnyObject) {
        
        // for quicker debugging
        //self.performSegueWithIdentifier("AuthSuccess", sender: sender)
        
        let username = tfUserName.text
        let password = tfPassword.text
        
        if username.isEmpty || password.isEmpty {
            showLoginAlert("Username and password are required.")
            
        } else {
            UdacityClient.sharedInstance().beginSession(tfUserName.text, password: tfPassword.text) { success, errorString in
                if success {
                    // segue to tabbed view upon succesful login
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("AuthSuccess", sender: sender)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showLoginAlert(errorString!)
                    })
                }
            }
        }
    }
    
    // Called when user taps button to sign up for Udacity
    @IBAction func signUp(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // Display an alert to the user warning of login failure
    func showLoginAlert(message: String) {
        
        let alertController = UIAlertController(title: "Error Logging In", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
