//
//  SQLLitePresenter.swift
//  TestApp
//
//  Created by Alina FESYK on 3/29/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import SQLite3

protocol SQLitePresenterDelegate: class {
    func updateViews()
}

class SQLitePresenter {
    
    weak var viewDelegate: SQLitePresenterDelegate?
    
    private var contentSaved: [String] = [] {
        didSet {
            print("didset contedSaved \(self.contentSaved)")
            contentToDisplay = contentSaved
        }
    }
    
    private var contentToDisplay: [String] = [] {
        didSet {
            print("update contentToDisplay \(self.contentToDisplay)")
            if searchString != "" {
                print("before filter contentToDisplay \(self.contentToDisplay)")
                contentToDisplay = contentSaved.filter {$0.contains(searchString)}

            }
        }
    }
    
    private var searchString: String = ""
    

    
    func addItem(with content: String) {
        contentSaved.append(content)
        viewDelegate?.updateViews()
    }
    
    func deleteItem(at index: Int) {
        
        let itemToDelete = contentToDisplay[index]
        contentSaved = contentSaved.filter{$0 != itemToDelete}

    }
    
    func searchItems(with substring: String) {
        
        searchString = substring
        contentToDisplay = contentSaved
        viewDelegate?.updateViews()
//        if substring != "" {
//            contentToDisplay = contentSaved.filter{$0.contains(substring) }
//        } else {
//            contentToDisplay = contentSaved
//        }
//
    }
    
}

// For table view Data source
extension SQLitePresenter {
    
    func getNumberOfSections() -> Int {
        return getNumberOfRows() != 0 ? 1 : 0
    }
    
    func getNumberOfRows() -> Int {
        return contentToDisplay.count
    }
    
    func getContent(for index: Int) -> String {
        return contentToDisplay[index]
    }
}
