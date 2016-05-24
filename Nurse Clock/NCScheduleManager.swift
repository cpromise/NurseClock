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
    
    override init () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        super.init()
    }
    
////    class var sharedInstance2 =
//    //1
//    class var sharedInstance: NCScheduleManager {
//        //2
//        struct Singleton {
//            //3
//            static let instance = NCScheduleManager()
//        }
//        //4
//        return Singleton.instance
//    }
    
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
//        return "X"
        
        if let schedule = getScheduleFor(NSDate()) {
            return schedule.1
        } else {
            return nil
        }
//        if let schedule = getThisMonthSchedule()?.valueForKey("schedule") as? String {
//            return schedule[Int(NCDateManager.date)!-1]
//        } else {
//            return nil
//        }
    }
    
    /**
     Get the schedule of this month.(presented by the System)
     -returns: schedule data if exists in Coredata. if not returns nil
     */
    func getThisMonthSchedule() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: "NCWorkSchedule")
        fetchRequest.predicate = NSPredicate(format:"month = \(NCDateManager.month)", "year = \(NCDateManager.year)")
        do{
            let resultEntities = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            guard resultEntities.count > 0 else { return nil }
            
            return resultEntities[0]
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
            setDenyToRegist()
            print("schedule saved Successfully.")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // 사용 편의를 위해서 튜플로 리턴함.
    // Coredata 사용시에는 $0으로 사용하고, 데이터 자체를 사용할 때는 $1로 사용하면 됨.
    func getScheduleFor(date:NSDate) -> (NSManagedObject, String)? {
        
        let fetchRequest = NSFetchRequest(entityName: "NCWorkSchedule")
        let beginning = date.startOfDay
        let end = date.endOfDay
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", beginning, end!)
        
        do{
            let resultEntities = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            print("\(resultEntities.count)개가 나왔음")
            guard resultEntities.count > 0, let schedule = resultEntities[0].valueForKey("schedule") as? String else { return nil }
            print("\(resultEntities.count)개가 나왔음")
            
            let entity = resultEntities[0]
            print("date in coredata : \(entity.valueForKey("date"))")
            return (entity, schedule)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    
    
    func insertSchedule(model:NCScheduleModel) {
        
        // TODO : 현재 저장되어있는 스케쥴표와 입력한 스케쥴표가 같으면 함수를 진행시킬 필요가 없음.
//        let currentSchedule = getMonthlySchedule(model.month, year: model.year)
  
//        if false {
//            return
//        }
        
        
        
        for tupleSchedule:(date:NSDate, schedule:String) in model.scheduleDic {
            if let scheduleObject = getScheduleFor(tupleSchedule.date)?.0 {
                scheduleObject.setValue(tupleSchedule.schedule, forKey: "schedule")
            } else {
                let entity = NSEntityDescription.entityForName("NCWorkSchedule", inManagedObjectContext: managedContext)
                let scheduleInfo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                scheduleInfo.setValue(Int(NCDateManager.year)!, forKey: "year")
                scheduleInfo.setValue(Int(NCDateManager.month)!, forKey: "month")
                scheduleInfo.setValue(tupleSchedule.schedule, forKey: "schedule")
                scheduleInfo.setValue(tupleSchedule.date, forKey: "date")
            }
            
            do {
                try managedContext.save()
                setDenyToRegist()
                print("schedule saved Successfully.")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
//    func getMonthlySchedule(month:Int, year:Int) -> NCScheduleModel?{
//        
//        var scheduleModel = NCScheduleModel(month: month, year: year)
//        let fetchRequest = NSFetchRequest(entityName: "NCWorkSchedule")
//        fetchRequest.predicate = NSPredicate(format:"month = \(NCDateManager.month)", "year = \(NCDateManager.year)")
//        do{
//            let resultEntities = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
//            
//            // 해당 달에 하나라도 근무 스케쥴이 입력되어 있으면 스케쥴object리턴. 하나도 없으면 nil리턴
//            guard resultEntities.count > 0 else { return nil }
//            
//            for object:NSManagedObject in resultEntities {
//                if let date = object.valueForKey("date"), schedule = object.valueForKey("schedule") {
//                    let tuple:(date:NSDate, schedule:String) = (date:date as! NSDate, schedule:schedule as! String)
//                    scheduleModel.scheduleList.append(tuple)
//                }
//            }
//            
//            return scheduleModel
//            
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//        
//        return nil
//    }
}

struct NCScheduleModel {
    var year:Int
    var month:Int
//    var dicSchedule:[NSDate:String] // 몇일에 어떤 근무인지
    
    var scheduleDic:[NSDate:String] // Schedule버튼을 누를 때 append되게 하고, count프로퍼티로 validation하기.
    
    init(month:Int, year:Int) {
        self.month = month
        self.year = year
        self.scheduleDic = Dictionary()
    }
}