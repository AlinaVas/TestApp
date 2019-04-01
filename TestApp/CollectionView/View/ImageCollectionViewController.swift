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
        if urlAdressTextField.text != "" {
            presenter.downloadArchive(with: urlAdressTextField.text!)
        }
    }
    
}

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageViewCell {
            cell.imageView.image = UIImage(contentsOfFile: presenter.getImageForCell(at: indexPath.row))
            return cell
        }
        return UICollectionViewCell()
    }
}

extension CollectionViewController: CollectionViewDelegate {
    func updateView() {

        collectionView.reloadData()
        urlAdressTextField.text = ""
    }
}

