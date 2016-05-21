//
//  NCDateManager.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class NCDateManager:NSObject {
    var flash:Bool = true
    let timeFormatter:NSDateFormatter = NSDateFormatter()
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    var lastUpdated:String?
    
    override init() {
        super.init()
        timeFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }
    
    static var year:String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.stringFromDate(NSDate())
    }
    static var month:String{
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.stringFromDate(NSDate())
    }
    static var date:String{
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    var strWork:String? {
        return NCScheduleManager.sharedInstance.todaySchedule
    }
    
    var strTime:String {
        if flash {
            timeFormatter.dateFormat = "h:mm a"
        } else {
            timeFormatter.dateFormat = "h mm a"
        }
        flash = !flash
        return timeFormatter.stringFromDate(NSDate())
    }
    
    var strDate:String {
        dateFormatter.dateFormat = "yyyy년 M월 dd일 (EEEE)"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    /**
     지금 시간이 낮인지 밤인지를 리턴.
     -returns: true if it's day time or false if it's night time.
     */
    var isDay:Bool {
        timeFormatter.dateFormat = "H"
        let hour = Int(timeFormatter.stringFromDate(NSDate()))
        
        return (hour>5 && hour<20)
    }
}