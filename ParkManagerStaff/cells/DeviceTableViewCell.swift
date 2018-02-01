//
//  DeviceTableViewCell.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 31/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    var user: User? = nil

    var device = Device() {
        didSet {
            let statusString = " (\(device.userId == nil ? "Свободно" : (user?.name ?? "Занято")))"
            let statusColor = device.userId == nil ? UIColor.green : UIColor.red
            let atrStatus = NSAttributedString(string: statusString, attributes: [NSAttributedStringKey.foregroundColor : statusColor])
            nameLabel.attributedText = NSAttributedString(string: device.name) + atrStatus
        }
    }
    
    var callback : ((Device) -> Void)? = nil

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            callback!(device)
        }
    }

}

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}
