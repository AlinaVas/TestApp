//
//  PanoramicViewController.swift
//  TestApp
//
//  Created by Alina Fesyk on 4/2/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit
import CTPanoramaView

class PanoramicViewController: UIViewController {

    var panoramaView: CTPanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        panoramaView = CTPanoramaView(frame: UIScreen.main.bounds)
        panoramaView.image = UIImage(named: "nightCity")
        panoramaView.panoramaType = .spherical
        panoramaView.controlMethod = .motion
        
        view.addSubview(panoramaView)
    }

}
