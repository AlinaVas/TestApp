//
//  SQLLitePresenter.swift
//  TestApp
//
//  Created by Alina FESYK on 3/29/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

// MARK: - SQLitePresenterDelegate
// method requirement for view delegate
protocol SQLitePresenterDelegate: class {
    func updateViews()
}

// MARK: - Presenter for SQLiteViewController
class SQLitePresenter {
    
    // view delegate for UI updates
    weak var viewDelegate: SQLitePresenterDelegate?
    
    // SQLite database for managing data in local storage
    private var database = SQLiteDatabase()
    
    // all stored items of data
    private var savedItems: [Item] = [] {
        didSet {
            displayedItems = savedItems
        }
    }
    
    // string by which displayed items are filtered
    private var searchString: String = ""
    
    // data items that need to be displayed
    private var displayedItems: [Item] = [] {
        didSet {
            if searchString != "" {
                displayedItems = savedItems.filter {$0.content.contains(searchString)}
            }
        }
    }
    

    init() {
        savedItems = database.readFromDatabase()
        displayedItems = savedItems
        viewDelegate?.updateViews()
    }
    
    deinit {
        database.closeDatabase()
    }
    
    func addItem(with content: String) {
        
        // get an id of stored in database item
        let id = database.addItem(with: content)
        guard id != nil else { return }
        
        // clean searchString so that all items could be visible
        searchString = ""
        savedItems.append(Item(id: id!, content: content))
        viewDelegate?.updateViews()
    }
    
    func deleteItem(at index: Int) {
        
        let itemToDelete = displayedItems[index]
        
        database.deleteItem(itemToDelete)
        savedItems = savedItems.filter{$0 !== itemToDelete}
    }
    
    func searchItems(with substring: String) {
        
        searchString = substring
        displayedItems = savedItems
        viewDelegate?.updateViews()
    }
}


// MARK: - Methods for tableView DataSource
extension SQLitePresenter {
    
    func getNumberOfSections() -> Int {
        return getNumberOfRows() != 0 ? 1 : 0
    }
    
    func getNumberOfRows() -> Int {
        return displayedItems.count
    }
    
    func getContent(for index: Int) -> String {
        return displayedItems[index].content
    }
}
