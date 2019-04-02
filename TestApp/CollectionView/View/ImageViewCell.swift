//
//  ImageViewCell.swift
//  TestApp
//
//  Created by Alina Fesyk on 4/1/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            if image != nil {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "noImage")
            }
        }
    }
    
}
