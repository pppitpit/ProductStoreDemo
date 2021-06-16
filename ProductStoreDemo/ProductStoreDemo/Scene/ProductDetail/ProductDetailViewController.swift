//
//  ProductDetailViewController.swift
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

protocol ProductDetailDisplayLogic: class{
    func displayProductDetail(viewModel: ProductDetail.Detail.ViewModel)
}

class ProductDetailViewController: UIViewController, ProductDetailDisplayLogic{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var interactor: ProductDetailBusinessLogic?
    var router: (NSObjectProtocol & ProductDetailRoutingLogic & ProductDetailDataPassing)?
    var product: ProductDetail.Detail.ViewModel.Product?
    
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
        let interactor = ProductDetailInteractor()
        let presenter = ProductDetailPresenter()
        let router = ProductDetailRouter()
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
        self.setFont()
        self.setColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
    }
    
    private func initialLoad(){
        
        let leftBarButtonItem = UIBarButtonItem(title: "<Back", style: .plain, target: self, action: #selector(self.back))
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ColorPallete.white, NSAttributedString.Key.font: FontStyle.HelveticaBold(size: 23)], for: .normal)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.title = "Detail"
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        let request = ProductDetail.Detail.Request()
        self.interactor?.getProductDetail(request: request)
    }
    
    private func setFont(){
        self.titleLabel.font = FontStyle.Helvetica(size: 22)
        self.priceLabel.font = FontStyle.HelveticaBold(size: 28)
        self.descriptionLabel.font = FontStyle.Helvetica(size: 18)
        self.newLabel.font = FontStyle.MontserratBold(size: 10)
    }
    
    private func setColor(){
        self.navigationController?.navigationBar.applyTheme()
        self.view.backgroundColor = ColorPallete.white
        self.scrollView.backgroundColor = ColorPallete.clear
        self.mainView.backgroundColor = ColorPallete.clear
        self.titleLabel.textColor = ColorPallete.veryDarkGray
        self.priceLabel.textColor = ColorPallete.red
        self.descriptionLabel.textColor = ColorPallete.darkGray
        self.newLabel.textColor = ColorPallete.red
    }
    
    @objc func back(){
        self.router?.popViewController()
    }
    
    func displayProductDetail(viewModel: ProductDetail.Detail.ViewModel){
        
        self.product = viewModel.product
        self.productImage.loadImage(from: viewModel.product.image)
        self.titleLabel.text = viewModel.product.title
        self.priceLabel.text = String(format: "%.2f", viewModel.product.price)
        self.newLabel.text = "NEW"
        self.newLabel.isHidden = !viewModel.product.isNewProduct
        
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.text = "\(viewModel.product.content)"
    }
}
