//
//  MasterTableViewCell.swift
//  SwiftChat
//
//  Created by Alexandr on 04.04.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var backView: UIView!

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if UIDevice.currentDevice().model == "iPad" && selected {
            backView.alpha = 1.0
        } else {
            backView.alpha = 0.0
        }
    }
}
