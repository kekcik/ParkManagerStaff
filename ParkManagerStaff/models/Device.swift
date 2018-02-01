//
//  Device.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 31/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import Foundation

class Device {
    var name: String
    var time: Int64
    var uid: String
    var userId: String?
    
    init(name: String, time: Int64, uid: String, userId: String?) {
        self.name = name
        self.time = time
        self.uid = uid
        self.userId = userId
    }
    
    init() {
        self.name = ""
        self.time = 0
        self.uid = ""
        self.userId = nil
    }
}
