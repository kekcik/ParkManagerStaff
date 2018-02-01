//
//  ApiManager.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 30/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class ApiManager {
    static let shared = ApiManager()
    
    func getDevice(with deviceId: String, userId:  String, callback: @escaping () -> Void) {
        var request = URLRequest(url: URL.init(string: "https://us-central1-parkmanager-192712.cloudfunctions.net/getDevice?userId=\(userId)&deviceId=\(deviceId)")!)
        request.httpMethod = "GET"
        Alamofire.request(request).responseJSON { response in
                callback()
        }
    }
    
    func putDevice(with deviceId: String, callback: @escaping () -> Void) {
        var request = URLRequest(url: URL.init(string: "https://us-central1-parkmanager-192712.cloudfunctions.net/putDevice?deviceId=\(deviceId)")!)
        request.httpMethod = "GET"
        Alamofire.request(request).responseJSON { response in
                callback()
        }
    }
    
    func fetchUsers(callback: @escaping (_ users: [User]) -> Void) {
        var request = URLRequest(url: URL.init(string: "https://us-central1-parkmanager-192712.cloudfunctions.net/fetchUsers")!)
        request.httpMethod = "GET"
        Alamofire.request(request).responseJSON { response in
            guard let data = response.data else { return; }
            let json = JSON(data: data)
            var result = [User]()
            if let users = json["users"].array {
                users.forEach({ (user) in
                    result.append(User.init(name: user["name"].stringValue, time: 0, uid: user["id"].stringValue))
                })
            }
            callback(result)
        }
    }
    
    func fetchDevices(callback: @escaping (_ devices: [Device]) -> Void) {
        var request = URLRequest(url: URL.init(string: "https://us-central1-parkmanager-192712.cloudfunctions.net/fetchDevices")!)
        request.httpMethod = "GET"
        Alamofire.request(request).responseJSON { response in
            guard let data = response.data else { return; }
            let json = JSON(data: data)
            var result = [Device]()
            if let devices = json["devices"].array {
                devices.forEach({ (device) in
                    result.append(Device.init(name: device["name"].stringValue, time: 0, uid: device["id"].stringValue, userId: device["userId"].string))
                })
            }
            callback(result)
        }
    }
}
