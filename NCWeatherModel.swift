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
    var currentWeather:[String:String]?
    var beginWeather:[String:String]?
    var finishWeather:[String:String]?
}