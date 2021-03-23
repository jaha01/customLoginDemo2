//
//  ListOfCategories.swift
//  CustomLoginDemo
//
//  Created by Jahongir on 12/25/20.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ListOfCategories: UICollectionViewController {

   var categoryArray: [Category] = []
        
        private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
        private let itemsPerRow: CGFloat = 3
        
        //MARK: View Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
             //createCategorySet()
            
        }
        override  func viewDidAppear(_ animated: Bool){
                super.viewDidAppear(animated)
                loadCategories()
            }
            


        // MARK: UICollectionViewDataSource




        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of items
            return categoryArray.count
        }

        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            // Configure the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        
            cell.generateCell(categoryArray[indexPath.row])
            return cell
        }

        //MARK: UICOLLERTIONVIEW DELEGATE REDIRECT!
        
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            performSegue(withIdentifier: "categoryToitemsSeg", sender: categoryArray[indexPath.row])
        }
        

            // MARK: Download categories
        private func loadCategories() {
            downloadCategoriesFromFirebase{( allCategories) in
                //print("we have", allCategories.count)
                self.categoryArray = allCategories
                self.collectionView.reloadData()
            }
            
        }
        
        //MARK: Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "categoryToitemsSeg"{
                let vc = segue.destination as! ItemsTableViewController
                vc.category = sender as! Category
                
            }
        }
    }


    extension ListOfCategories: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemsAt indexPath: IndexPath)-> CGSize{
        
        let paddingSpace = sectionInsets.left*(itemsPerRow+1)
        let availableWidth = view.frame.width - paddingSpace
        let withPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: withPerItem, height: withPerItem)
        
    }

    func  collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int)-> UIEdgeInsets{

            return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
        
    }
        
    }

