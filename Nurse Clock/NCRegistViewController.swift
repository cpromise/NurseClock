//
//  NCRegistViewController.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation
import UIKit

class NCRegistViewController: UIViewController {
    
    let scheduleModel = NCScheduleModel()
    
    @IBOutlet weak var lbThisMonth: UILabel!
    @IBOutlet weak var tfWorkSchedule: UITextField!
    
    @IBAction func onTouchedCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTouchedSave(sender: AnyObject) {
        let validateResult = NCScheduleModel.validateSchedule(tfWorkSchedule.text)
        if validateResult.0 {
            scheduleModel.insertSchedule(tfWorkSchedule.text!)
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
    }
}