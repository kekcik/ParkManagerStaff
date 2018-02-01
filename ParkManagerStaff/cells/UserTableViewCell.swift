//
//  UserTableViewCell.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 31/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var user = User() {
        didSet {
            nameLabel.text = user.name
        }
    }
    
    var callback : ((User) -> Void)? = nil

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            callback!(user)
        }

    }

}
