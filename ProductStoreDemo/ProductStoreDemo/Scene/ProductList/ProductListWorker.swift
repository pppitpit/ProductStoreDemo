//
//  ProductListWorker.swift
//  ProductStoreDemo
//
//  Created by Pit on 12/6/2564 BE.
//  Copyright (c) 2564 BE ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

class ProductListWorker{
    
    func getProductList(completion: @escaping([ProductModel]) -> Void, failure: @escaping (String) -> Void){
        ProductAPI.sharedInstance.getProductList(completion: completion, failure: failure)
    }
}
