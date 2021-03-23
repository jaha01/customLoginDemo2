//
//  CategoryCollectionViewController.swift
//  shopApp
//
//  Created by Jahongir on 9/10/20.
//  Copyright © 2020 Jahongir. All rights reserved.
//

import UIKit
import JGProgressHUD

class BasketViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalItem: UILabel!
    
    @IBOutlet weak var totalPrice: UILabel!
    
    @IBOutlet weak var checkBtn: UIButton!
    
    //MARK: Vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemsIds : [String] = []
    
    var envinotment : String = PayPalEnvironmentNoNetwork{
        willSet (newEnvinotment) {
            if (newEnvinotment != envinotment) {
                PayPalMobile.preconnect(withEnvironment: newEnvinotment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration()
    
    let hud = JGProgressHUD(style: .extraLight)

    
    //MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = footerView
        
        setupPayPal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            self.updateTotalLabel(true)
        }
    }
    
    //MARK: IBActions
    

    @IBAction func checkOutBtnPressed(_ sender: Any) {
        
        if MUser.currentUser()!.onBoard {
            
            payButtonPressed()
            
        } else {
            
            self.hud.textLabel.text = "Please complete your profile!"
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    //MARK: - Download basket
    private func loadBasketFromFirestore(){
        
        downloadBasketFromFirestore(MUser.currentIds()){ (basket) in
            
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems(){
        
        if basket != nil {
            downloadItems(basket!.itemIds) { (allItem) in
                self.allItems = allItem
                self.tableView.reloadData()
                self.updateTotalLabel(false)
            }
        }
    }
    //MARK: Helper functions
    
    
 /*
    func tempFunction() {
        for item in allItems {
            purchasedItemsIds.append(item.id)
        }
    }*/
    
    private func updateTotalLabel(_ isEmpty: Bool){
        if isEmpty {
            totalItem.text = "0"
            totalPrice.text = returnBasketTotalPrice()
        } else {
            totalItem.text = "\(allItems.count)"
            totalPrice.text = returnBasketTotalPrice()
        }
        
        checkoutBtnStatusUpdate()
        
    }
    
    
    private func returnBasketTotalPrice() -> String {
    
    var totalprice = 0.0
    
        for item in allItems{
            totalprice += item.price
        }
        return "Total price: " + convertToCurrency(totalprice)
    }
    
    
    
    private func emptyTheBasket(){
        
        purchasedItemsIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        
        updateBasketInFirestore(basket!, withValues: [kITEMIDS: basket!.itemIds]) { (error) in
            
            if error != nil {
                print("Error update basket ", error!.localizedDescription)
            } //else {
                
            //}
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]){
        
        if MUser.currentUser() != nil {
            
            let newItems = MUser.currentUser()!.purchasedItenIds + itemIds
            
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : newItems]) { (error) in
                
                if error != nil {
                    print("Error adding purchased items ", error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Navigation
    
    private func showItemView(withItem: Item){
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ItemView") as! ItemViewController
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    
    
    
    //MARK: - Control checkoutButton
    private func checkoutBtnStatusUpdate(){
        
        checkBtn.isEnabled = allItems.count > 0
        
        if checkBtn.isEnabled{
            checkBtn.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
      } else {
            disableCheckoutBtn()
        }
        
    }
    
    private func disableCheckoutBtn(){
        
        checkBtn.isEnabled = false
        checkBtn.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    
    private func removeItemFrombasket(itemId: String){
        
        for i in 0 ..< basket!.itemIds.count{
            
            if itemId == basket!.itemIds[i]{
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
    //MARK: - PayPAl
    
    private func setupPayPal(){
        
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "IBT BANK"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .both
        
    }
    
    private func payButtonPressed(){
        
        var itemsToBuy : [PayPalItem] = []
        
        for item in allItems {
            let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            
            purchasedItemsIds.append(item.id)
            itemsToBuy.append(tempItem)
        }
        let subTotal = PayPalItem.totalPrice(forItems: itemsToBuy)
        
        //optional
        let shippingCost = NSDecimalNumber(string: "50.0")
        let tax = NSDecimalNumber(string: "5.00")
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: shippingCost, withTax: tax)
        
        let total = subTotal.adding(shippingCost).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Payment to IBT Bank", intent: .sale)
        
        payment.items = itemsToBuy
        payment.paymentDetails = paymentDetails
        
        if payment.processable {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            
            present(paymentViewController!, animated: true, completion: nil)
            
        } else {
            print("Payment not processible")
        }
    }
}


extension BasketViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
       
        return cell
    }
    
    
    //MARK: UITableView Delegete
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let itemToDelete = allItems[indexPath.row]
            
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFrombasket(itemId: itemToDelete.id)
            
            updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
                
                if error != nil {
                    print("Error updating the basket", error!.localizedDescription)
                }
                
                self.getBasketItems()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
        
    }
}


extension BasketViewController : PayPalPaymentDelegate{
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        
        print("paypal payment cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        paymentViewController.dismiss(animated: true) {
            
            self.addItemsToPurchaseHistory(self.purchasedItemsIds)
            self.emptyTheBasket()
        }
    }
    
    
}
