//
//  NCClockViewController.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import UIKit

class NCClockViewController: UIViewController {
    @IBOutlet weak var lbWork: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var btnRegistSchedule: UIButton!
    
    let dateManager = NCDateManager()
    let scheduleModel = NCScheduleModel()
    let vc = NCRegistViewController()
    
    //날씨
    let weatherModel = NCWeatherModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
        updateLabels()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if scheduleModel.appFirstExcuted {
            alertShouldRegistWorkSchedule()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels() {
        toggleScheduleView()
        lbDate.text = dateManager.strDate
        lbTime.text = dateManager.strTime
    }
    
    func alertShouldRegistWorkSchedule() {
        let alertController = UIAlertController(title: "소희의 시계", message: "환영합니다.\n근무 스케쥴을 입력하러 갈까요?", preferredStyle: .Alert)
        
        let actionYes = UIAlertAction(title: "네", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.goToRegistWorkSchedule()
        })
        let actionNo = UIAlertAction(title: "나중에", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.onTouchedDenyToRegist()
        })
        
        presentViewController(alertController, animated: true, completion: nil)
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        
    }
    
    func goToRegistWorkSchedule() {
        performSegueWithIdentifier("segueToRegistController", sender: self)
    }
    
    func onTouchedDenyToRegist() {
        scheduleModel.setDenyToRegist()
    }
    
    func toggleScheduleView() {
        if let todayWork = dateManager.strWork {
            lbWork.text = todayWork
            lbWork.hidden = false
            btnRegistSchedule.hidden = true
        } else {
            lbWork.hidden = true
            btnRegistSchedule.hidden = false
        }
    }
    
    @IBAction func onTouchedRegistSchedule(sender: AnyObject) {
    }
    
}

