//
//  NCRegistViewController.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar

class NCRegistViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    var modelSchedule:NCScheduleModel = NCScheduleModel(month: 5, year: 2016)
    
    // MARK: - Storyboard
    @IBOutlet weak var calendarView: NCCalendarView!
    
    @IBOutlet weak var lbThisMonth: UILabel!
    @IBOutlet weak var tfWorkSchedule: UITextField!
    
    @IBAction func onTouchedCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTouchedSave(sender: AnyObject) {
        let validateResult = NCScheduleManager.validateSchedule(tfWorkSchedule.text)
        if validateResult.0 {
            NCScheduleManager.sharedInstance.insertSchedule(tfWorkSchedule.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            var message = ""
            if let numOfScheduleNeeded = validateResult.1 {
                message = "\(Int(NCDateManager.month)!)월에는 \(numOfScheduleNeeded)개의 근무 수가 필요합니다."
            } else {
                message = "에러가 발생하여 저장에 실패하였습니다. Error:00001"
            }
            let alertController = UIAlertController(title: "소희의 시계", message: message, preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "확인", style: .Default, handler: nil)
            alertController.addAction(actionOk)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    // TODO: 스케줄 입력하기 편한 UX로 개선해야함
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbThisMonth.text = "\(NCDateManager.year)년 \(Int(NCDateManager.month)!)월"
        calendarView.collectionView.delegate = calendarView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory warning at \(self.description)")
    }
    
    //TODO : 한번에 한 개의 달에만 근무를 입력할 수 있게한다.
    //5월1일부터 31일까지 이런식으로만.
    //마지막날의 근무가 입력되면 저장하시겠습니까? alert을 띄우자.
    @IBAction func onTouchedDate(sender: AnyObject) {
        
        let touchedBtn = sender as! UIButton
        let schedule = touchedBtn.titleLabel!.text!
        
        var currentDate:NSDate? = calendarView.selectedDate
        if currentDate == nil {
            currentDate = calendarView.today
        }
        
        modelSchedule.scheduleDic[calendarView.selectedDate] = schedule
        
        //////////////////////////////
        let indexPath = calendarView.indexPathForDate(currentDate)
        print("\(calendarView.selectedDate)에는 \(schedule)입니다.")
        
        if let cell = calendarView.collectionView.cellForItemAtIndexPath(indexPath) as? FSCalendarCell {
            var color:UIColor
            switch schedule {
            case "D":
                color = UIColor(netHex: 0x89C4F4)
            case "E":
                color = UIColor(netHex: 0xFF8300)
            case "N":
                color = UIColor(netHex: 0x2C3E50)
            case "W":
                color = UIColor(netHex: 0xFF1E1D)
            default:
                color = UIColor.clearColor()
            }
            cell.shapeLayer.backgroundColor = color.CGColor
        }
        //////////////////////////////
        
        currentDate = currentDate!.dateByAddingTimeInterval(60*60*24*1)
        calendarView.selectDate(currentDate!)
        
        
        

        if modelSchedule.scheduleDic.count > 30 {
            
            let alertController = UIAlertController(title: nil, message: "5월의 근무가 저장됩니다.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "확인", style: .Default, handler: { [weak self] (UIAlertAction) in
                NCScheduleManager.sharedInstance.insertSchedule(self!.modelSchedule)
                self!.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            
        } else {
            print("dictionary에는 \(modelSchedule.scheduleDic.count)개 ㅎㅎ")
        }

        
    }
    
    // MARK: - FSCalendar Delegate Method
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print(calendar.selectedDate)
    }
    
    func calendar(calendar: FSCalendar, subtitleForDate date: NSDate) -> String? {
        
        if let schedule = NCScheduleManager.sharedInstance.getScheduleFor(date) {
            return schedule.1
        } else {
            return nil
        }
    }
    
}