
//  NCWeatherCollectionViewDataSource.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 8..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation

class NCWeatherCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var weatherModel: NCWeatherModel?
    
//    init(weatherModel: NCWeatherModel) {
//        self.weatherModel = weatherModel
//        super.init()
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let keys = weatherModel?.inNhours?.keys {
            return keys.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("weatherCell", forIndexPath: indexPath) as! NCWeatherCollectionViewCell
        
        guard let hour = weatherModel?.supportedTime[indexPath.row]
            , temp = weatherModel?.inNhours?["\(hour)"]?["temp"]
            , iconName = weatherModel?.inNhours?["\(hour)"]?["skyIcon"]
            , rainProb = weatherModel?.inNhours?["\(hour)"]?["rainProb"] else {return cell}
        
        cell.lbTemperature.text = "\(Double(temp)!)°C"
        cell.imgWeatherIcon.image = UIImage(named: iconName)
        cell.lbForecastProb.text = "\(NSString(string: rainProb).integerValue)"
        
        // N시간 뒤
        cell.lbTimeAfter.text = "\(hour)시간 뒤"
        
        return cell
    }
}

extension NCWeatherCollectionViewDataSource: UICollectionViewDelegate {
    
}