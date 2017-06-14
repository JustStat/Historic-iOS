//
//  PlaceTableViewCell.swift
//  Historic
//
//  Created by Kirill Varlamov on 13.06.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import FoldingCell

class PlaceTableViewCell: FoldingCell {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainNameLabel: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var detailButton: UIButton!
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
