//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView


class AddItemViewController: UIViewController {

    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var desciptionField: UITextView!
    
    //MARK: Vars
    var category: Category!
    var gallery: GalleryController!
    let hud = JGProgressHUD(style: .light)
    
    var activityIndicator: NVActivityIndicatorView?
    
    var itemImages: [UIImage?] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

        override func viewDidAppear(_ animated: Bool) {
              super.viewDidAppear(animated)
              
              activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 30, y: self.view.frame.height/2 - 30, width: 60, height: 60), type: .ballRotateChase, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
          }
          
        // Do any additional setup after loading the view.
    
    
    @IBAction func doneButton(_ sender: Any) {
        dismissKeyboard()
              
              if fieldsAreCompleted() {
                  saveToFirebase()
              } else {
                  self.hud.textLabel.text = "All fields are required!"
                  self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                  self.hud.show(in: self.view)
                  self.hud.dismiss(afterDelay: 2.0)
                  }
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        
        dismissKeyboard()
    }
    
    // MARK: helper func
    
    private func fieldsAreCompleted()->Bool{
        
        return(textField.text != "" && priceField.text != "" && desciptionField.text != "")
    }
    
    private func dismissKeyboard(){
        
        self.view.endEditing(false)
    }
    
    private func popTheView(){
        self.navigationController?.popViewController(animated: true)
    }
    
        //MARK: Save Item
        
      private func saveToFirebase(){
            
            showLoadingIndicator()
            
            let item = Item()
            item.id = UUID().uuidString
            item.name = textField.text!
            item.categoryId = category.id
            item.description = desciptionField.text
            item.price = Double(priceField.text!)
            
            if itemImages.count>0{
                
                uploadImages(images: itemImages, itemId: item.id) { (imageLinkArray) in
                    
                    item.imageLinks = imageLinkArray
                    saveItemToFirestore(item)
                    saveItemToAlgolia(item: item)
                    
                    self.hideLoadingIndicator()
                    
                    self.popTheView()
                    
                }
                
            } else {
                saveItemToFirestore(item)
                saveItemToAlgolia(item: item)
                popTheView()
            }
        }
        
        
        //MARK: Activity Indicator
        
        private func showLoadingIndicator(){
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
        private func hideLoadingIndicator(){
            
            if activityIndicator != nil {
                activityIndicator!.removeFromSuperview()
                activityIndicator!.stopAnimating()
            }
        }
        
        //MARK: Show Gallery
        
        private func showImageGallery(){
            
            self.gallery = GalleryController()
            self.gallery.delegate = self
            
            Config.tabsToShow = [.imageTab, .cameraTab]
            Config.Camera.imageLimit = 6
            
            self.present(self.gallery, animated: true, completion: nil)
        }
        
    }

    extension AddItemViewController: GalleryControllerDelegate{
        func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
            
            if images.count>0 {
                
                Image.resolve(images: images) { (resolvedImages) in
                    self.itemImages = resolvedImages
                }
            }
                
             controller.dismiss(animated: true, completion: nil)
        }
        
        func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
             controller.dismiss(animated: true, completion: nil)
        }
        
        func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
             controller.dismiss(animated: true, completion: nil)
        }
        
        func galleryControllerDidCancel(_ controller: GalleryController) {
            controller.dismiss(animated: true, completion: nil)
        }
        
        
    
}
