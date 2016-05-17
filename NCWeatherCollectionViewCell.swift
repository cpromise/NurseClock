//
//  NCWeatherCollectionViewCell.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 8..
//  Copyright © 2016년 SH. All rights reserved.
//

import UIKit

class NCWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    @IBOutlet weak var lbTemperature: UILabel!
    @IBOutlet weak var imgForecastIcon: UIImageView!
    @IBOutlet weak var lbForecastProb: UILabel!
    @IBOutlet weak var lbTimeAfter: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

