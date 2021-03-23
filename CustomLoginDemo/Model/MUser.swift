//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import Foundation
import FirebaseAuth

class MUser {
    
    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItenIds: [String]
    
    var fullAddress: String?
    var onBoard: Bool
    
    //MARK: - Initializers
    
    init(_objectId: String, _email: String, _firstName: String, _lastName: String) {
        
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        onBoard = false
        purchasedItenIds = []
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL] {
            
            email = mail as! String
        } else {
            email = " "
        }
        
        if let fname = _dictionary[kFIRSTNAME] {
            
            firstName = fname as! String
        } else {
            firstName = " "
        }
        
        if let lname = _dictionary[kLASTNAME] {
            
            lastName = lname as! String
        } else {
            lastName = " "
        }
        
        fullName = firstName + " " + lastName
        
        if let faddress = _dictionary[kFULLADDRESS] {
            
            fullAddress = faddress as! String
        } else {
            fullAddress = " "
        }
        
        if let onboard = _dictionary[kONBOARD] {
            
            onBoard = onboard as! Bool
        } else {
            onBoard = false
        }
        
        if let purchaseIds = _dictionary[kPURCHASEDITEMIDS] {
            
            purchasedItenIds = purchaseIds as! [String]
        } else {
            purchasedItenIds = []
        }

    }
    
    //MARK: - Return current user
    
    class func currentIds() -> String{
        
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> MUser? {
     
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER){
                
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
        
    
    //MARK: - Login func
    
    class func loginUserWith(email: String, password: String, compilition: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error  == nil {
                
                if authDataResult!.user.isEmailVerified{
                    
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    compilition(error, true)
                } else {
                    print("email is not Verified")
                    compilition(error, false)
                }
                
            } else {
                print("email is not verifiel")
                compilition(error, false)
            }
        }
    }
    
    //MARK - Register User
    
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            if error == nil {
                //send email verification
                authDataResult!.user.sendEmailVerification { (error) in
                    
                    print("auth email verification error: ", error?.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Resend link methods
    class func reserPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) {(error) in
            completion(error)
        }
    }
    
    class  func resendVerificationEmail(email: String, competion: @escaping (_ error: Error) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print("resend email error", error?.localizedDescription)
            })
        })
    }
    

    


class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void){
    
    do {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize()
        completion(nil)
        
    } catch let error as NSError {
        completion(error)
        
    }
    
    }

}
     //MARK: - Конец основного класса

//MARK: - Download User

func downloadUserFromFirestore(userId: String, email: String) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
            print("download current user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            //ther is no user, save new in firestore
            
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }
}


//MARK: - Save User to Firebase

func saveUserToFirestore(mUser: MUser){
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        
        if error != nil {
            print("error savinr User \(error!.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary){
    
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}


//MARK: - Helper Function

func userDictionaryFrom(user: MUser)-> NSDictionary{
    
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.fullAddress ?? "", user.onBoard, user.purchasedItenIds], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kFULLADDRESS as NSCopying, kONBOARD as NSCopying, kPURCHASEDITEMIDS as NSCopying])
}


//MARK: Update User

func updateCurrentUserInFirestore(withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void){
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        FirebaseReference(.User).document(MUser.currentIds()).updateData(withValues){(error) in
            
            completion(error)
            
            if error == nil {}
            saveUserLocally(mUserDictionary: userObject)
        }
    }
}
