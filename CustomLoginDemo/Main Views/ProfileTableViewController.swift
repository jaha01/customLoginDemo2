//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var finishRegBtn: UIButton!
    
    @IBOutlet weak var purchaseHistBtn: UIButton!
    
    //MARK: - VARS
    var editBarButtonOutlet: UIBarButtonItem!
    
    //MARK: View lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()  // Will delete empty cells
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // checked logged in status
         checkLoginStatus()
         //createRightBarButton(title: "Edit")
          checkOnboardingStatus()
    }
    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

 
    // MARK: - TbaleView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Helpers
   
    private func checkOnboardingStatus(){
        
        if MUser.currentUser() != nil {
            
            if MUser.currentUser()!.onBoard {
                finishRegBtn.setTitle("Account is Active", for: .normal)
                finishRegBtn.isEnabled = false
            } else {
                finishRegBtn.setTitle("Finish registration", for: .normal)
                finishRegBtn.isEnabled = true
                finishRegBtn.tintColor = .red
            }
            purchaseHistBtn.isEnabled = true
            
        } else {
            
            finishRegBtn.setTitle("Logget Out", for: .normal)
            finishRegBtn.isEnabled = false
            purchaseHistBtn.isEnabled = false
        }
    }
    
    
  private func checkLoginStatus() {
        if MUser.currentUser() == nil {
            createRightBarButton(title: "Login")
        } else {
            createRightBarButton(title: "Edit")
     }
    }
    
    private func createRightBarButton(title: String) {
        
        editBarButtonOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonItemPressed))
        
        self.navigationItem.rightBarButtonItem = editBarButtonOutlet
    }
    
    //MARK: IBActions
   
    @objc func rightBarButtonItemPressed(){
        
        if editBarButtonOutlet.title == "Login" {
            //show login view
            showLoginView()
        } else {
            // go to profile
            goToEditProfile()
        }
    }
    
    private func showLoginView(){
        
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
    }
    
    private func goToEditProfile(){
        
        performSegue(withIdentifier: "profileToEdit", sender: self)
    }

    
    
    
}
