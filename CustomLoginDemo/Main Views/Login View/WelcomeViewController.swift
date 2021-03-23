//
//  CategoryCollectionViewController.swift
//
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var PassTextField: UITextField!
    
    @IBOutlet weak var reSendBtn: UIButton!
    
    
    //MARK: - Vars
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    
    //MARK: - View lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 30, y: self.view.frame.height/2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 1.0, alpha: 1.0), padding: nil)
    }

    //MARK: IBActions
    
    @IBAction func cancelBtn(_ sender: Any) {
        dissmissView()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        
        if textFieldHaveText() {
            loginUser()
        } else {
            hud.textLabel.text="All feilds are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func forgotBtn(_ sender: Any) {
        
        if emailTextField.text != ""{
            resetThePassword()
        } else {
            hud.textLabel.text="Please insert email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
        
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        if textFieldHaveText() {
            registerUser()            
        } else {
            hud.textLabel.text="All feilds are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func resendBtn(_ sender: Any) {
        
        MUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            
            print("resend email error", error.localizedDescription)//Here should be  error?.localizedDescription
        }
    }
    
    
    //MARK: - Helpers
    
    private func resetThePassword(){
        
        MUser.reserPasswordFor(email: emailTextField.text!) { (error)  in
            
            if error == nil {
                self.hud.textLabel.text = "Reser password email sent!"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }

    
    private func loginUser(){
        showLoadingIndicator()
        
        MUser.loginUserWith(email: emailTextField.text!, password: PassTextField.text!) { (error, isEmailVerified) in
                  if error == nil {
                    
                    if isEmailVerified{
                        self.dissmissView()
                        print("Email is verified")
                    } else {
                        self.hud.textLabel.text = "Please Verified  your email!"
                        self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud.show(in: self.view)
                        self.hud.dismiss(afterDelay: 2.0)
                        self.reSendBtn.isHidden = false
                    }
                  } else {
                    print("error login in the User", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                  }
                  
                  self.hideLoadingIndicator()
              }
          }
          
    
    
    private func registerUser(){
        
        showLoadingIndicator()
        
         MUser.registerUserWith(email: emailTextField.text!, password: PassTextField.text!) { (error) in
            if error == nil {
                self.hud.textLabel.text="Verification Email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                print("error registration", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
    }
    
    private func textFieldHaveText()->Bool{
        return(emailTextField.text != "" && PassTextField.text != "" )
    }
    
    private func dissmissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func showLoadingIndicator(){
        
        if activityIndicator != nil {
            
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
            
        }
        
    }
    
    private func hideLoadingIndicator(){
        
        if activityIndicator != nil {
            
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
            
        }
        
    }
}
