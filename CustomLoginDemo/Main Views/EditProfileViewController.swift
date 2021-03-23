//
//  EditProfileViewController.swift
//  CustomLoginDemo
//
//  Created by Jahongir on 11/18/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: VARS
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: View lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUserInfo()
    }
    
//MARK: IBActions

    @IBAction func saveBtn(_ sender: Any) {
        dismissKeyboard()
        
        if textFieldsHaveText(){
            
            let withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surnameTextField.text!, kFULLNAME: (nameTextField.text! + "" + surnameTextField.text!), kFULLADDRESS: addressTextField.text!]
            
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                
                if  error == nil {
                    self.hud.textLabel.text = "Updated"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                } else {
                    print("error updating user ", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
            
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func logOutBtn(_ sender: Any) {
        
        logOutUser()
    }
    
    
    //MARK: UpdateUI

    private func loadUserInfo(){
        
        if MUser.currentUser() != nil {
            
            let currentUser = MUser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK: - Helpers funcs
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logOutUser(){
        
        MUser.logOutCurrentUser{ (error) in
            if error == nil {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            } else {
                print ("error login out ", error!.localizedDescription)
            }
        }
    }
}
