//
//  PhotoCell.swift
//  
//
//  Created by Tim Barnard on 2/4/16.
//
//

import UIKit

class PhotoCell: UITableViewCell {

    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
