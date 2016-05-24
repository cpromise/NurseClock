//
//  NCWeatherModel.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation

/*
 TODO
 1. 서브스크립트를 만들어보자.
     1. D키를 받으면 출근:7, 퇴근16
     2. E키를 받으면 출근:14, 퇴근23
     3. N키를 받으면 출근:20, 퇴근8
     에 해당하는 날씨를 리턴해서 출근때 날씨, 퇴근때 날씨를 리턴해줄 수 있도록!
 
 2. 비올 확률도 표시해보자.
 3. 모델은 Main
 */

struct NCWeatherModel {
    let supportedTime = [4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,61]
    var location:String?
    
    // 기상예보 관측 시간
    var timeForecast:String?
 
    // key : 지금으로 부터 N시간 뒤
    // value : N시간 후의 날씨 정보
        // key : skyCode, skyDesc, rainProb, temp, skyIcon
    var inNhours:[String:[String:String]]? = Dictionary()
    
    // 현재 날씨 (if needed)
    var currentWeather:[String:String]?
    
}