//
//  ImageCollectionViewController.swift
//  TestApp
//
//  Created by Alina Fesyk on 4/1/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var urlAdressTextField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.isHidden = true
        }
    }
    
    let presenter = CollectionViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionViewLayout()
        collectionView.dataSource = self
        presenter.viewDelegate = self
    }
    
    private func setCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        let itemSize = (view.bounds.width - 2) / CGFloat(3)
        
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionView.collectionViewLayout = layout
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        urlAdressTextField.resignFirstResponder()
        if urlAdressTextField.text != "" {
            presenter.downloadArchive(with: urlAdressTextField.text!)
            progressView.progress = 0
        }
    }
    
}


// MARK: - UICollectionViewDataSource methods

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numb of items")
        return presenter.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("numb of items")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageViewCell {
            cell.image = UIImage(contentsOfFile: presenter.getImageForCell(at: indexPath.row))
            return cell
        }
        return UICollectionViewCell()
    }
}



// MARK: - CollectionViewDelegate methods 

extension CollectionViewController: CollectionViewDelegate {

    // reloads CollectionView when new data is availiable
    
    func updateCollectionView() {
        collectionView.reloadData()
        urlAdressTextField.text = ""
    }
    
    // indicates how much of a file has been downloaded
    
    func updateProgressView(progress: Float) {
        progressView.progress = progress
    }
    
    // Activity indicator is shown instead of progressView
    // when downloading progress info is not available
    
    func showActivityIndicator() {
        if !activityIndicator.isAnimating {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

