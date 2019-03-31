//
//  SQLiteItem.swift
//  TestApp
//
//  Created by Alina Fesyk on 3/31/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

class Item {
    var id: Int
    var content: String
    
    init(id: Int, content: String) {
        self.content = content
        self.id = id
    }
}
