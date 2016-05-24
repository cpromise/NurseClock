//
//  NCCalendarView.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation
import FSCalendar

class NCCalendarView: FSCalendar {
    
}


extension NCCalendarView:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let dateCell = cell as! FSCalendarCell
        
        dateCell.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
    }
    
}