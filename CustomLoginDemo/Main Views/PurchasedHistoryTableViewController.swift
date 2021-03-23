//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import JGProgressHUD
import EmptyDataSet_Swift

class PurchasedHistoryTableViewController: UITableViewController {

    //MARK: - Vars
    var itemArray: [Item] = []
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self 
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadItems()
        
        self.hud.textLabel.text = "Clicked on Purchase button"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 10.0)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell

        cell.generateCell(itemArray[indexPath.row])

        return cell
    }
    

    //MARK: - Load items
    private func loadItems(){
        
        downloadItems(MUser.currentUser()!.purchasedItenIds) { (allItems) in
            self.itemArray = allItems
            print("we have \(allItems.count) items purchased")
            self.tableView.reloadData()
           
        }
    }

}



extension PurchasedHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate{
   
 func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
     return UIImage(named: "empty_page")
 }
    /*  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Items to Display")
    }
    
    
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }*/
}
