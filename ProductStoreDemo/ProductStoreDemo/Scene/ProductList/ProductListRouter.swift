//
//  ProductListRouter.swift
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

@objc protocol ProductListRoutingLogic{
    func routeToProductDetail(segue: UIStoryboardSegue?)
}

protocol ProductListDataPassing{
    var dataStore: ProductListDataStore? { get }
}

class ProductListRouter: NSObject, ProductListRoutingLogic, ProductListDataPassing{
    
    weak var viewController: ProductListViewController?
    var dataStore: ProductListDataStore?
    
    func routeToProductDetail(segue: UIStoryboardSegue?){
        
        if let segue = segue {
            let destinationVC = segue.destination as! ProductDetailViewController
            var destinationDS = destinationVC.router!.dataStore!
            self.passDataToProductDetail(source: dataStore!, destination: &destinationDS)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
            var destinationDS = destinationVC.router!.dataStore!
            self.passDataToProductDetail(source: dataStore!, destination: &destinationDS)
            self.navigateToProductDetail(source: viewController!, destination: destinationVC)
        }
    }
    
    func navigateToProductDetail(source: ProductListViewController, destination: ProductDetailViewController){
        source.show(destination, sender: nil)
    }
    
    func passDataToProductDetail(source: ProductListDataStore, destination: inout ProductDetailDataStore){
        destination.currentProduct = source.currentProduct
    }
}
