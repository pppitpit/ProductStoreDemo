//
//  ProductListViewController.swift
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

protocol ProductListDisplayLogic: class{
    func displayProductList(viewModel: ProductList.List.ViewModel)
    func displayProductDetail()
    func showAlertFailure(error: ProductList.List.Error)
}

class ProductListViewController: UIViewController, ProductListDisplayLogic{
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    
    var interactor: ProductListBusinessLogic?
    var router: (NSObjectProtocol & ProductListRoutingLogic & ProductListDataPassing)?
    var productList: [ProductList.List.ViewModel.Product] = []
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: Setup
    private func setup(){
        let viewController = self
        let interactor = ProductListInteractor()
        let presenter = ProductListPresenter()
        let router = ProductListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.initialLoad()
        self.setColor()
    }
   
    private func initialLoad(){
        
        self.setUI()
        self.initialCollection()
        self.hideRetry()
        self.startLoading()
        self.getProductList()
    }
    
    private func setUI(){
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.title = "Products"
        self.retryButton.titleLabel?.font = FontStyle.HelveticaBold(size: 18)
        self.retryButton.setTitle("Tab to Retry", for: .normal)
    }
    
    private func initialCollection(){
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func getProductList(){
        let request = ProductList.List.Request()
        self.interactor?.getProductList(request: request)
    }
    
    private func startLoading(){
        self.loadingView.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    private func stopLoading(){
        self.loadingView.isHidden = true
        self.loadingIndicator.stopAnimating()
    }
    
    private func showRetry(){
        self.retryView.isHidden = false
    }
    
    private func hideRetry(){
        self.retryView.isHidden = true
    }

    private func setColor(){
        self.navigationController?.navigationBar.applyTheme()
        self.mainView.backgroundColor = ColorPallete.gray
        self.collectionView.backgroundColor = ColorPallete.clear
        self.loadingView.backgroundColor = ColorPallete.gray
        self.loadingIndicator.color = ColorPallete.black
        self.retryView.backgroundColor = ColorPallete.gray
        self.retryButton.setTitleColor(ColorPallete.black, for: .normal)
    }
    
    func displayProductList(viewModel: ProductList.List.ViewModel){
        self.productList = viewModel.productList
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.stopLoading()
                self.collectionView.reloadData()
            }
        }
    }
    
    func displayProductDetail(){
        self.router?.routeToProductDetail(segue: nil)
    }
    
    func showAlertFailure(error: ProductList.List.Error){
        
        DispatchQueue.main.async {
            self.stopLoading()
            self.showErrorDialog(message: error.errorDescription, completion: { [weak self] in
                self?.showRetry()
            })
        }
    }
    
    @IBAction func actionRetry(_ sender: Any) {
        
        self.hideRetry()
        self.startLoading()
        self.getProductList()
    }
}

extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if self.productList.count == 0{
            return CGSize.zero
        }
        else{
            return CGSize(width: collectionView.frame.width, height: 50)
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "productHeaderCell", for: indexPath) as! ProductCollectionReusableView
        header.setUI()
        header.setFont()
        header.setColor()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionViewCell
        cell.setUI(product: self.productList[indexPath.item])
        cell.setFont()
        cell.setCornerRadiusAndShadow()
        cell.setColor()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.interactor?.selectCurrentProduct(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice().userInterfaceIdiom == .phone{
            let width = (collectionView.frame.size.width - 45) / 2
            let height = width + 60
            return CGSize(width: width, height: height)
        }
        else{
            let width = (collectionView.frame.size.width - 60) / 3
            let height = width + 40
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
}
