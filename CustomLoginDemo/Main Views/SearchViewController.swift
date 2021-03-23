//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {

    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchOptionView: UIView!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    
    //MARK: - vars
    var searchResults: [Item] = []
    
    var activityIndicator : NVActivityIndicatorView?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDudChange(_:)), for: UIControl.Event.editingChanged)
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self 
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 30, y: self.view.frame.height/2 - 30, width: 60, height: 60), type: .ballRotateChase, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    
    @IBAction func showSearchBtn(_ sender: Any) {
        
        dismissKeyboard()
        showSearchField()
    }
    
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        if searchTextField.text != "" {
            
            searchInFirebase(forName: searchTextField.text!)
            emptyTextField()
            animateSearchOption()
            dismissKeyboard()
        }
    }
    
    //MARK: - Search database
    
    private func searchInFirebase(forName: String){
        
        showLoadingIndicator()
        searchAlgolia(searchString: forName) { (itemIds) in
            
            downloadItems(itemIds) { (allItems) in
                
                self.searchResults = allItems
                self.tableView.reloadData()
                
                self.hideLoadingIndicator()
                
            }
        }
    }
    
    
    //MARK: - Helpers
    
    private func emptyTextField(){
        searchTextField.text = ""
    }
    
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    @objc func textFieldDudChange(_ textField: UITextField){
        
        print("typing")
        searchBtn.isEnabled = textField.text != ""
        
        if searchBtn.isEnabled{
            searchBtn.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        } else {
            disableSearchButton()
        }
    }
    
    private func disableSearchButton(){
        searchBtn.isEnabled = false
        searchBtn.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    private func showSearchField(){
        
        disableSearchButton()
        emptyTextField()
        animateSearchOption()
    }
    
    //MARK: animations
    
    private func animateSearchOption(){
        UIView.animate(withDuration: 0.5){
            self.searchOptionView.isHidden = !self.searchOptionView.isHidden
        }
    }
    
    //MARK: Activity indicator
    
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
    
    private func showItemView(withItem: Item){
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true  )
    }
}



extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(searchResults[indexPath.row])
        
        return cell
    }
    //MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        showItemView(withItem: searchResults[indexPath.row])
    }
    
    
}

extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate{
   
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
