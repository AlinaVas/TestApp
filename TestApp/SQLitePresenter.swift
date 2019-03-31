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
            contentToDisplay = contentSaved
        }
    }
    
    private var contentToDisplay: [String] = [] {
        didSet {
            viewDelegate?.updateViews()
        }
    }
    
    func getNumberOfRows() -> Int {
        return contentToDisplay.count
    }
    
    func getContent(for index: Int) -> String {
        return contentToDisplay[index]
    }
    
    func addItem(with content: String) {
        contentSaved.append(content)
        
        
    }
    
    func searchItems(with substring: String) {
        if substring != "" {
            contentToDisplay = contentSaved.filter{$0.contains(substring) }
        } else {
            contentToDisplay = contentSaved
        }
        
    }
    
}
