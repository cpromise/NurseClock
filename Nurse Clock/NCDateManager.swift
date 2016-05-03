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
    let scheduleModel = NCScheduleModel()
    var lastUpdated:String?
    
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
        return scheduleModel.todaySchedule
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
    
    override init() {
        super.init()
        timeFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }
    
    
}