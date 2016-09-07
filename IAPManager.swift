//
//  IAPManager.swift
//  Cute Dog Videos
//
//  Created by AL on 5/4/16.
//  Copyright © 2016 AL. All rights reserved.
//

import UIKit
import StoreKit

protocol IAPManagerDelegate {
    func managerDidRestorePurchases()
}


class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    
    static let sharedInstance = IAPManager()
    
    var request: SKProductsRequest!
    var products: NSArray!
    
    var delegate:IAPManagerDelegate?
    
    func setupInAppPurchases(){
        self.validateProductIdentifiers(self.getProductIdentifiersFromMainBundle())
    
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        }
    
    func getProductIdentifiersFromMainBundle() -> NSArray {
        var identifiers = NSArray()
        if let url = NSBundle.mainBundle().URLForResource("iap_product_ids", withExtension: "plist"){
            identifiers = NSArray(contentsOfURL: url)!
        }
        
        return identifiers
    }
    
    func validateProductIdentifiers(identifiers:NSArray) {
        let productIdentifiers = NSSet(array: identifiers as [AnyObject])
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        self.request = productRequest
        productRequest.delegate = self
        productRequest.start()
                
    }
    
    func createPaymentRequestForProduct(product:SKProduct) {
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func verifyReceipt(transaction:SKPaymentTransaction?){
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL!
        if let receipt = NSData(contentsOfURL: receiptURL) {
            //Receipt exists
            let requestContents = ["receipt-data" : receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)), "password" : ""]
        
            //Perform request
            do {
                let requestData = try NSJSONSerialization.dataWithJSONObject(requestContents, options: NSJSONWritingOptions(rawValue: 0))
        
                //Build URL Request
                let storeURL = NSURL(string: "https://sandbox.itunes.apple.com/verifyReceipt")
                let request = NSMutableURLRequest(URL: storeURL!)
                request.HTTPMethod = "Post"
                request.HTTPBody = requestData
        
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: { (responseData:NSData?, response: NSURLResponse?, error:NSError?) -> Void in

                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .MutableLeaves) as! NSDictionary

                        print(json)

                        if (json.objectForKey("status") as! NSNumber) == 0 {
                            let receipt_dict = json["receipt"] as! NSDictionary
                            if let purchases = receipt_dict["in_app"] as? NSArray{
                                self.validatePurchaseArray(purchases)
                            }

                            if transaction != nil {
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction!)
                            }

                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.managerDidRestorePurchases()
                            })

                        } else {
                            //Debug
                            print(json.objectForKey("status") as! NSNumber)
                        }
                        
                    } catch {
                        print(error)
                    }
                })
                task.resume()
                
            } catch {
                print(error)
            }
            
        } else {
            
            print("No Receipt")
        }
        
    }
    
    func validatePurchaseArray(purchases: NSArray) {
        for purchase in purchases as! [NSDictionary]{
            
            
            self.unlockPurchasedFunctionalityForProductIdentifier(purchase["product_id"] as! String)
        }
    }
    
    func unlockPurchasedFunctionalityForProductIdentifier(productIdentifer:String) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifer)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func lockPurchasedFunctionalityForProductIdentifier(productIdentifer:String) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: productIdentifer)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.products = response.products
        print("@==================@")
        print(self.products)
        print("@==================@")
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as [SKPaymentTransaction] {
            switch transaction.transactionState {
            case .Purchasing:
                print("Purchasing")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            case .Deferred:
                print("Deferred")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            case .Failed:
                print("Failed")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    print(transaction.error?.localizedDescription)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case .Purchased:
                print("Purchased")
                self.verifyReceipt(transaction)
            case .Restored:
                print("Restored")
            }
        }
    }
    
    func restorePurchases(){
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    func requestDidFinish(request: SKRequest) {
        self.verifyReceipt(nil)
    }

    
}

