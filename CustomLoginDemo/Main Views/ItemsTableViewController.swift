//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//
import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController {

    //MARK:VArs
    var category: Category?
    
    var itemArray: [Item] = []
    
        //MARK: View lifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

       tableView.tableFooterView = UIView()
       self.title = category?.name
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if category != nil {
            loadItems()
        }
    }

    // MARK: - Table view data source

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          // #warning Incomplete implementation, return the number of rows
          return itemArray.count
      }

    
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell

         cell.generateCell(itemArray[indexPath.row])
          // Configure the cell...

          return cell
      }
    
    
    //MARK: past data to detail product page ЗДЕСЬ Я ПОПЫТАЛСЯ
    /*
    func tableView(tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vc?.img.image = category?.image
        vc?.lbl.text = "Что нибудь"
        self.navigationController?.pushViewController(vc!, animated: true)
        print("Tapped")
    }*/
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemToAddItemSeg" {
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    

    
    private func showItemView(_ item: Item){
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ItemView") as! ItemViewController
        itemVC.item = item
        
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
    //MARK: Load Items
      private func loadItems(){
          
          downloadItemsFromFirebase(category!.id) { (allItems) in
              //print ("We have \(allItems.count) itemw for this category")
              self.itemArray = allItems
              self.tableView.reloadData()
          }
      }
    
}


extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate{
   
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
