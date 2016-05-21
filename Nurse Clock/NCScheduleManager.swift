//
//  NCScheduleManager.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class NCScheduleManager: NSObject {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext:NSManagedObjectContext
    var lastUpdated:String?
    
    static let sharedInstance = NCScheduleManager()
    
    // 앱이 첫 실행인지를 판단
    var appFirstExcuted:Bool {
        let fetchRequest = NSFetchRequest(entityName: "NCLastUpdated")
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            let resultEntities:[NSManagedObject] = result as! [NSManagedObject]
            if resultEntities.count == 0 {
                return true
            } else {
                lastUpdated = resultEntities[0].valueForKey("lastUpdated") as? String
                return false
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return true
    }
    
    // 시스템의 날짜 기준으로 오늘의 근무를 리턴
    var todaySchedule:String? {
        if let schedule = getThisMonthScheduleValue() {
            return schedule[Int(NCDateManager.date)!-1]
        } else {
            return nil
        }
    }
    
    func getThisMonthScheduleValue() -> String? {
        return getThisMonthSchedule()?.valueForKey("schedule") as? String
    }
    
    /**
     Get the schedule of this month.(presented by the System)
     -returns: schedule data if exists in Coredata. if not returns nil
     */
    func getThisMonthSchedule() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: "NCWorkSchedule")
        do{
            let resultEntities = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for row in resultEntities {
                let year = row.valueForKey("year") as? Int
                let month = row.valueForKey("month") as? Int
                if year == Int(NCDateManager.year)! && month == Int(NCDateManager.month)! {
                    return row
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    /**
     Make app stop asking the users whether to insert the schedule or not.
     Just make a empty row and insert to Coredata.
     Thereafter application becomes to decide to show an alert or not judging by the data.
     */
    func setDenyToRegist() {
        let entity =  NSEntityDescription.entityForName("NCLastUpdated", inManagedObjectContext:managedContext)
        let agreeInfo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //3
        print("\(NCDateManager.year)\(NCDateManager.month)")
        agreeInfo.setValue(true, forKey: "denyToRegist")
        agreeInfo.setValue("\(NCDateManager.year)\(NCDateManager.month)", forKey: "lastUpdated")
        
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    /**
     Insert monthly schedule to Coredata.
     - parameter schedule: string representing the schedule of the month.
     */
    func insertSchedule(schedule:String) {
        if let scheduleObject = getThisMonthSchedule() {
            scheduleObject.setValue(schedule, forKey: "schedule")
        } else {
            let entity =  NSEntityDescription.entityForName("NCWorkSchedule", inManagedObjectContext:managedContext)
            let scheduleInfo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            scheduleInfo.setValue(Int(NCDateManager.year)!, forKey: "year")
            scheduleInfo.setValue(Int(NCDateManager.month)!, forKey: "month")
            scheduleInfo.setValue(schedule, forKey: "schedule")
        }
        
        do {
            try managedContext.save()
            
            print("schedule saved Successfully.")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
    }
    
    /**
     Compare the length of the Schedule String with the number of dates of the month.
     - parameter inputValue: string representing the schedule of the month.
     - returns: validation for the input string and the number of dates of the month.
     */
    static func validateSchedule(inputValue:String?) -> (Bool, Int?) {
        
        if let input:String = inputValue {
            let month = Int(NCDateManager.month)!
            switch month {
            case 1,3,5,7,8,10,12:
                return (input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 31, 31)
            case 4,6,9,11:
                return (input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 30, 30)
            case 2:
                let year = Int(NCDateManager.year)!
                if year%4==0 && year%100 != 0 || year%400 == 0 {
                    // 윤년일 경우에는 29자리
                    return (input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 29, 29)
                } else {
                    // 아닐 경우에는 28자리
                    return (input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 28, 28)
                }
            default:
                return (false, nil)
            }
        }
        
        return (false, nil)
    }
    
    
    override init () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        super.init()
    }
    
}

/*
 "abcde"[0] === "a"
 "abcde"[0...2] === "abc"
 "abcde"[2..<4] === "cd"
 */
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}