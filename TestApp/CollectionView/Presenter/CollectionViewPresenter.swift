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
    func updateCollectionView()
    func updateProgressView(progress: Float)
    func showActivityIndicator()
    func hideActivityIndicator()
}


// MARK: - Presenter for CollectionViewController

class CollectionViewPresenter: NSObject {
    
    weak var viewDelegate: CollectionViewDelegate?
    
    private var imageURLs: [Image] = []
    
    private let archiveName = "ImageArchive"
    
    private let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    
    // downloading archive using given URL
    // URL must be a direct link to a ZIP file
    func downloadArchive(with urlString: String)  {
        
        guard let remoteArchiveURL = URL(string: urlString) else {
            print("Wrong URL")
            return
        }
        
        // clean data source
        imageURLs.removeAll()
        DispatchQueue.main.async {
            self.viewDelegate?.updateCollectionView()
        }
        
        let destinationURL = documentsURL.appendingPathComponent("\(archiveName).zip")
        
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
        
        // initialize the URLSession
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        //  set download task
        let task = urlSession.downloadTask(with: urlRequest)
//        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
//            print("********!!!!!!",progress.fractionCompleted)
//        }
        task.resume()
    }
    
    
    
    // unpack downloaded ZIP file to 'imagesDirectory', rewriting previous downloads
    private func unzipArchive(from sourceURL: URL)  {
        print("unzip")
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
    
    
    
    // extract all images of .jpg and .png format 
    private func getImagesFromDirectory(url: URL) {
        print("getImg")
        print(url.path)
        
        do {
            let directoryContent = try FileManager.default.contentsOfDirectory(atPath: url.path)
            
            for item in directoryContent {
                print(item)
                if item.hasSuffix(".jpg") || item.hasSuffix(".png") {
                    imageURLs.append(Image(urlPath: url.appendingPathComponent(item).path))
                }
            }
        } catch {
            print("Failed to read directory: \(error)")
        }
        print("view update \(imageURLs.count)")
        DispatchQueue.main.async {
            self.viewDelegate?.updateCollectionView()
        }
    }
}

// MARK: - Data for CollectionView DataSource

extension CollectionViewPresenter {
    
    func getNumberOfItems() -> Int {
        return imageURLs.count
    }
    
    func getImageForCell(at index: Int) -> String {
        return imageURLs[index].urlPath
    }
    
}

extension CollectionViewPresenter: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("!!!PROGRESS: \(totalBytesWritten)  of  \(totalBytesExpectedToWrite)")
            DispatchQueue.main.async {
                self.viewDelegate?.updateProgressView(progress: progress)
            }
        } else {
            DispatchQueue.main.async {
                self.viewDelegate?.showActivityIndicator()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Downloading finished")
        
//        let destinationURL = documentsURL.appendingPathComponent("")
//
//        // move file to a custom destination
//        do {
//            try FileManager.default.moveItem(at: location, to: destinationURL)
//        } catch {
//            print(error.localizedDescription)
//        }
        
        DispatchQueue.main.async {
            self.viewDelegate?.hideActivityIndicator()
        }
        unzipArchive(from: location)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.viewDelegate?.hideActivityIndicator()
        }
        if let error = error {
            print("Error downloading: \(error.localizedDescription)")
        }
    }
}
