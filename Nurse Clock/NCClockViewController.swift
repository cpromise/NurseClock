//
//  NCClockViewController.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import UIKit

class NCClockViewController: UIViewController {
    
    // 스케쥴, 시계 관련
    let dateManager = NCDateManager()

    // 날짜가 바뀔 때만 스케쥴 텍스트를 바꾸도록 변경 (코어데이터 조회 최소화)
    var todayDate = NCDateManager.date {
        didSet {
            if todayDate != oldValue {
                toggleScheduleView()
            }
        }
    }
    @IBOutlet weak var lbWork: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var btnRegistSchedule: UIButton!
    @IBOutlet weak var lbLocation: UILabel!
    @IBOutlet weak var lbTimeForecast: UILabel!
    
    @IBAction func tmpToggleAction(sender: AnyObject) {
        toggleScheduleView()
    }
    // 날씨 관련
    let weatherManager = NCWeatherManager()
    @IBOutlet weak var collectionView: NCWeatherCollectionView! // 연속 날씨 컬렉션 뷰
    let weatherDataSource = NCWeatherCollectionViewDataSource()
    var weatherModel: NCWeatherModel = NCWeatherModel() {
        didSet{
            weatherDataSource.weatherModel = weatherModel
            collectionView.reloadData()
            lbLocation.text = weatherModel.location
            
            if let timeForecast = weatherModel.timeForecast {
                lbTimeForecast.text = "측정 시간 : \(timeForecast[0...15])"
            } else {
                lbTimeForecast.text = "측정 시간을 가져오지 못했습니다."
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = weatherDataSource
        
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
        updateLabels()
        toggleScheduleView()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            self.weatherManager.requestWeatherInfo {
                [weak self] NCWeatherModel in
                
                self!.weatherModel = NCWeatherModel
            }
        }
        
        print("\(NSDate())")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NCScheduleManager.sharedInstance.appFirstExcuted {
            alertShouldRegistWorkSchedule()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleScheduleView()
    }
    
    func updateLabels() {
        lbDate.text = dateManager.strDate
        lbTime.text = dateManager.strTime
        
        // 날짜가 바뀌면 스케쥴텍스트를 변경하도록 해줌
        todayDate = NCDateManager.date
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
        NCScheduleManager.sharedInstance.setDenyToRegist()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory warning at \(self.description)")
    }

}

