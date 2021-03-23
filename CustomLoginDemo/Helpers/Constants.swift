//
//  SceneDelegate.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//


import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let homeViewController = "tabBar"
        static let loginViewController = "LoginVC"
        
    }
    
    
}


public let kFILEREFERENCE = "gs://market-82404.appspot.com"
public let kALGOLIA_APP_ID = "3ED35AWCNF"
public let kALGOLIA_SEARCH_KEY = "aa0197aed0b56951d764eb51a3b53a48"
public let kALGOLIA_ADMIN_KEY = "a3a9ce6111168893ff7a7b7c0dd88d00"


//FirebaseHeader
public let kUSER_PATH = "User"
public let kCATEGORY_PATH = "Category"
public let kITENS_PATH = "Items"
public let kBASKET_PATH = "Basket"



//Category
public let kNAME = "name"
public let kIMAGENAME = "imageName"
public let kOBJECTID = "objectid"

//Item
public let kCATEGORYID = "categoryId"
public let kDESCRIPTION = "description"
public let kPRICE = "price"
public let kIMAGELINKS = "imageLinks"

//Basket
public let kOWNERID = "ownerId"
public let kITEMIDS = "itemIds"


//User
public let kEMAIL = "email"
public let kFIRSTNAME = "firstName"
public let kLASTNAME = "lastName"
public let kFULLNAME = "fullName"
public let kCURRENTUSER = "currentUser"
public let kFULLADDRESS = "fullAddress"
public let kONBOARD = "onBoard"
public let kPURCHASEDITEMIDS = "purchasedItemIds"
