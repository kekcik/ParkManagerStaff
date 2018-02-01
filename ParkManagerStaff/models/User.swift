//
//  User.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 31/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import Foundation

class User {
    var name: String
    var time: Int64
    var uid: String
    
    init(name: String, time: Int64, uid: String) {
        self.name = name
        self.time = time
        self.uid = uid
    }
    
    init() {
        self.name = ""
        self.time = 0
        self.uid = ""
    }
}
