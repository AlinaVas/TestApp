//
//  SQLiteDatabase.swift
//  TestApp
//
//  Created by Alina Fesyk on 3/31/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import SQLite3

// MARK: - SQLite Database for managing data in local storage

struct SQLiteDatabase {
    
    // URL path to a database file
    private var fileURL: URL?
    
    // pointer to a databse
    private var databasePtr: OpaquePointer?
    
    
    
    init() {
        
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS Items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT);
            """
        
        // create database file
        do {
            fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("ItemsDatabase.sqlite")
        } catch {
            print(error.localizedDescription)
            return
        }

        // open database
        if sqlite3_open(fileURL!.path, &databasePtr) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error opening database: \(error)")
            return
        }

        // create table
        if sqlite3_exec(databasePtr, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error creating table: \(error)")
            return
        }
    }
    
    
    
    // fetch all the data stored in database
    func readFromDatabase() -> [Item] {
        
        var itemArray: [Item] = []
        
        // select query
        let selectItemQuery = "SELECT id, content FROM Items;"

        // statement pointer
        var selectStatement: OpaquePointer?

        // preparing the query
        if sqlite3_prepare_v2(databasePtr, selectItemQuery, -1, &selectStatement, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error preparing SELECT: \(error)")
            return itemArray
        }
        
        // going through all the records
        while(sqlite3_step(selectStatement) == SQLITE_ROW) {
            let id = sqlite3_column_int(selectStatement, 0)
            let content = String(cString: sqlite3_column_text(selectStatement, 1))

            itemArray.append(Item(id: Int(id), content: content))
        }

        return itemArray
    }
    
    
    
    // add item and return its database id
    func addItem(with content: String) -> Int? {
        
        // insert query
        let insertQuery = "INSERT INTO Items (content) VALUES (?);"
        
        // statement pointer
        var insertStatement: OpaquePointer?

        // prepare the query
        if sqlite3_prepare_v2(databasePtr, insertQuery, -1, &insertStatement, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error preparing INSERT: \(error)")
            return nil
        }

        // binding the parameter 'content'
        if sqlite3_bind_text(insertStatement, 1, content, -1, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("failure binding content: \(error)")
            return nil
        }

        // executing the query to insert item
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("failure inserting item: \(error)")
            return nil
        }

        sqlite3_finalize(insertStatement)
        return idOfSavedItem()
    }
    
    
    
    // get the id of a last stored item
    private func idOfSavedItem() -> Int? {
        
        // select query
        let selectQuery = "SELECT last_insert_rowid();"
        
        // statement pointer
        var selectStatement: OpaquePointer?
        
        // prepare the query
        if sqlite3_prepare_v2(databasePtr, selectQuery, -1, &selectStatement, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error preparing SELECT: \(error)")
            return nil
        }
        
        // getting a record
        if (sqlite3_step(selectStatement) == SQLITE_ROW) {
            let id = sqlite3_column_int(selectStatement, 0)
            return Int(id)
        }
        
        sqlite3_finalize(selectStatement)
        return nil
    }
    
    
    
    // delete item from database
    func deleteItem(_ item: Item) {
    
        guard item.id != nil else { return }
        
        // delete query
        let deleteQuery = "DELETE FROM Items WHERE id = \(item.id!);"
        
        // statement pointer
        var deleteStatement: OpaquePointer?
        
        // prepare the query
        if sqlite3_prepare_v2(databasePtr, deleteQuery, -1, &deleteStatement, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("error preparing DELETE: \(error)")
            return
        }
        
        // check if item deleted
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            let error = String(cString: sqlite3_errmsg(databasePtr)!)
            print("failure deleting item: \(error)")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    
    // close database before app terminates
    func closeDatabase() {
        sqlite3_close(databasePtr)
    }
}
