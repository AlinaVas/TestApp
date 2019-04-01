//
//  CollectionViewPresenter.swift
//  TestApp
//
//  Created by Alina Fesyk on 4/1/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import ZIPFoundation

// MARK: - Delegate protocol for CollectionView updates

protocol CollectionViewDelegate: class {
    func updateView()
}


// MARK: - Presenter for CollectionViewController

class CollectionViewPresenter {
    
    weak var viewDelegate: CollectionViewDelegate?
    
    private var imageURLs: [String] = []
    
    let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    
    // downloading archive using given URL
    func downloadArchive(with urlString: String)  {
        
        guard let remoteArchiveURL = URL(string: urlString) else {
            print("Wrong URL")
            return
        }
        
        let destinationURL = documentsURL.appendingPathComponent("ImageArchive.zip")
        
        // remove archive if it already exists
        if FileManager().fileExists(atPath: destinationURL.path) {
            do {
                try FileManager.default.removeItem(atPath: destinationURL.path)
            } catch {
                print("failed to remove existing file: \(error)")
            }
        }
        
        // set request
        var urlRequest = URLRequest.init(url: remoteArchiveURL)
        urlRequest.httpMethod = "get"
        urlRequest.setValue("application/zip", forHTTPHeaderField: "content-Type")
        
        //  set download task
        let task = URLSession.shared.downloadTask(with: urlRequest, completionHandler: { (location, response, error) in
            
            // check if file was downloaded successfully
            if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
               let location = location, error == nil {
            
                // move file to a custom destination
                do {
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                } catch {
                    print(error.localizedDescription)
                }

                self.unzipArchive(from: destinationURL)
            }
        })
        task.resume()
    }
    
    
    
    // unpack downloaded ZIP file to 'imagesDirectory', rewriting previous downloads
    private func unzipArchive(from sourceURL: URL)  {
        
        let destinationURL = documentsURL.appendingPathComponent("imagesDirectory")
        
        // remove directory if it already exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                try FileManager.default.removeItem(atPath: destinationURL.path)
            } catch {
                print("failed to remove existing file: \(error)")
            }
        }
        
        // create new directory and unzip
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            print("Extraction of ZIP archive failed with error: \(error)")
        }
        
        getImagesFromDirectory(url: destinationURL)
    }
    
    
    
    // extract all images from a given directory, considering that images are named with numbers
    // and have .jpg format: 1.jpg, 2.jpg, ...
    private func getImagesFromDirectory(url: URL) {
        
        var imgCount = 1
        var imgPath = url.appendingPathComponent("\(imgCount).jpg")
        
        while FileManager.default.fileExists(atPath: imgPath.path) {
            imageURLs.append(imgPath.path)
            imgCount += 1
            imgPath = url.appendingPathComponent("\(imgCount).jpg")
        }
        
        DispatchQueue.main.async {
            self.viewDelegate?.updateView()
        }
    }
}

// MARK: - Data for CollectionView DataSource

extension CollectionViewPresenter {
    
    func getNumberOfItems() -> Int {
        return imageURLs.count
    }
    
    func getImageForCell(at index: Int) -> String {
        return imageURLs[index]
    }
    
}
