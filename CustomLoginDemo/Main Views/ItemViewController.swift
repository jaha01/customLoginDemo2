//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {


    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: Vars
    var item : Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let sectionInsets = UIEdgeInsets(top: 00.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHieght : CGFloat = 196.0
    private let itemsPerRow: CGFloat = 1
     
    //MARK: View lyfecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        downloadPictures()
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "basket"), style: .plain, target: self, action: #selector(self.addToBasketPressed))]
    }
    
    
// MARK: Download Images
    private func downloadPictures(){
        
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks){(allImages) in
                if allImages.count > 0{
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
//MARK: Setup UI
    private func setupUI(){
        if item != nil{
            self.title = item.name
            nameLabel.text = item.name!
            priceLabel.text = convertToCurrency(item.price)
            print("IN SETUPUI")
            descriptionTextView.text = item.description

       }
        
    }
    
    //MARK: IBActions
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasketPressed(){
        
        //TODO: check if user is logged in ahow login view
        if MUser.currentUser() != nil {
            downloadBasketFromFirestore(MUser.currentIds()) { (basket) in
            
            if  basket == nil {
                self.createNewBasket()
            } else {
                basket!.itemIds.append(self.item.id)
                self.updateBasket(basket: basket!, withValues: [kITEMIDS: basket!.itemIds])
            }
        }
            
        } else {
            showLoginView()
        }
    }
    
    //MARK: - Add to basket
    
    private func createNewBasket(){
        
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentIds()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        
       
        
    }
    
    private func updateBasket(basket: Basket, withValues: [String: Any]){
        
        updateBasketInFirestore(basket, withValues: withValues){(error) in
            
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                       self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                       self.hud.show(in: self.view)
                       self.hud.dismiss(afterDelay: 2.0)
                print("error updatinf basket", error!.localizedDescription)
            }else {
                       self.hud.textLabel.text = "Added to basket!"
                       self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                       self.hud.show(in: self.view)
                       self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
}


extension ItemViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        
        return cell
    }
    
    
}


extension ItemViewController: UICollectionViewDelegateFlowLayout{

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemsAt indexPath: IndexPath)-> CGSize{
    
    let availableWidth = collectionView.frame.width - sectionInsets.left
    print(availableWidth)
    return CGSize(width: availableWidth, height: cellHieght)
    
}

func  collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int)-> UIEdgeInsets{

        return sectionInsets
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
    return sectionInsets.left
    
    }
    
    
    //MARK: - Show login View
    
    private func showLoginView(){
        
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
    }
    
}

