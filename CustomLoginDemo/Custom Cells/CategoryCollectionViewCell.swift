//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLAbel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func generateCell (_ category: Category){
          nameLAbel.text = category.name
          imageView.image = category.image
      }
    
}
