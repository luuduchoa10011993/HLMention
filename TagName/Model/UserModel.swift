//
//  UserModel.swift
//  TagName
//
//  Created by HoaLD on 3/25/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    var id = ""
    var name = ""
    
    init(_ id: String,_ name: String) {
        self.id = id
        self.name = name
    }
    
    func getDisplayName() -> String {
        return name
    }
    
    func getTagID() -> String {
        return "[:\(id):]"
    }
}
