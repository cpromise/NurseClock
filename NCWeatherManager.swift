//
//  NCWeatherManager.swift
//  Nurse Clock
//
//  Created by SH on 2016. 5. 3..
//  Copyright © 2016년 SH. All rights reserved.
//

import Foundation
import Alamofire

/*
 1. SK planet 날씨API를 사용함. 키 값:a6bea27a-892f-327d-88b4-0c3c49413e36
 2. 언제 요청할 것인가
     1. 앱 실행시
     2. 새로 고침 누를 시
     3. 출퇴근 시간 쯤.. 정확히 언제?
     4. 아니면 그냥 5분마다?
 3. 오프날은 어떤 데이터를 보여줄 것인가?
 */

class NCWeatherManager: NSObject {
    let weatherURL = "http://apis.skplanetx.com/weather/forecast/3days"
    let appKey = "a6bea27a-892f-327d-88b4-0c3c49413e36"
    
    // TODO : 현재 위치를 기준으로 API요청하기
    // 또는 병원이나 원하는 위치 미리 지정해둘 수 있게
    let param = [
        "version":"1",
        "city":"경기",
        "county":"구리시",
        "village":"수택3동"
    ]

    /**
     Start to request to SK Planet WeatherAPI
     On success, closure parameter will change UI of NCClockViewController.
     On fail, function just ends without any results.
     
     - parameter completion: closure which will be excuted when request finishes successfully.
     */
    func requestWeatherInfo(completion:((NCWeatherModel)->())?) {
        
        Alamofire.request(.GET, weatherURL, parameters: param, encoding: .URL, headers: ["appKey":appKey]).responseJSON { (response) in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                guard let weatherModel = self.makeWeatherModel(JSON) where completion != nil else {return}
                completion!(weatherModel)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }

        }
    }
    
    /**
     Make WeatherModel using the result of SK Planet WeatherAPI.
     
     - parameter JSON: result of SK Planet WeatherAPI
     - returns: WeatherModel made by JSON or nil if error occured while parsing.
     */
    func makeWeatherModel(JSON:AnyObject) -> NCWeatherModel? {
        
        // 날씨 딕셔너리 파싱
        guard let tmp = JSON as? [String:AnyObject]
            ,let weather = tmp["weather"] as? [String:AnyObject]
            ,let forecast3days = weather["forecast3days"] as? [AnyObject]
            ,let foreCastsDic = forecast3days[0] as? [String:AnyObject] else {return nil}
        
        // 날씨 정보 파싱
        guard let fcst3hour	= foreCastsDic["fcst3hour"] as? [String:AnyObject]
            , let sky = fcst3hour["sky"] as? [String:AnyObject]
            , let rain = fcst3hour["precipitation"] as? [String:AnyObject]
            , let temp = fcst3hour["temperature"] as? [String:AnyObject] else {return nil}
        
        var weatherModel = self.makeValidWeatherModel(skyTemp: sky, rainModel: rain, tempModel: temp)
        
        // 지역명 파싱
        guard let grid = foreCastsDic["grid"] as? [String:AnyObject]
            ,let city = grid["city"] as? String
            ,let county = grid["county"] as? String
            ,let village = grid["village"] as? String
            else {return nil}
        weatherModel.location = "\(city) \(county) \(village)"
        
        // 관측 시간
        guard let timeForecast = foreCastsDic["timeRelease"] as? String else {return nil}
        weatherModel.timeForecast = timeForecast
        
        print("weatherModel.timeForecast : \(weatherModel.timeForecast)")
        
//        weatherModel.in4hours["skyCode"] = sky["code4hour"] as? String
//        weatherModel.in4hours["skyDesc"] = sky["name4hour"] as? String
//        weatherModel.in4hours["rainProb"] = rain["prob4hour"] as? String
//        weatherModel.in4hours["rainAmount"] = rain["rain4hour"] as? String
//        weatherModel.in4hours["temp"] = temp["temp4hour"] as? String
//        
//        weatherModel.in7hours["skyCode"] = sky["code7hour"] as? String
//        weatherModel.in7hours["skyDesc"] = sky["name7hour"] as? String
//        weatherModel.in7hours["rainProb"] = rain["prob7hour"] as? String
//        weatherModel.in7hours["rainAmount"] = rain["rain7hour"] as? String
//        weatherModel.in7hours["temp"] = temp["temp7hour"] as? String
//        
//        weatherModel.in13hours["skyCode"] = sky["code13hour"] as? String
//        weatherModel.in13hours["skyDesc"] = sky["name13hour"] as? String
//        weatherModel.in13hours["rainProb"] = rain["prob13hour"] as? String
//        weatherModel.in13hours["rainAmount"] = rain["rain13hour"] as? String
//        weatherModel.in13hours["temp"] = temp["temp13hour"] as? String
        
        return weatherModel
    }
    
    func makeValidWeatherModel(skyTemp sky: [String:AnyObject], rainModel rain: [String:AnyObject], tempModel temp: [String:AnyObject]) -> NCWeatherModel{
        var weatherModel = NCWeatherModel()
        
        for hour in weatherModel.supportedTime {
            guard let skyCode = sky["code\(hour)hour"] as? String
                ,let skyDesc = sky["name\(hour)hour"] as? String
                ,let rainProb = rain["prob\(hour)hour"] as? String
//                ,let rainAmount = rain["rain\(hour)hour"] as? String
                ,let temp = temp["temp\(hour)hour"] as? String else {break}
            
            guard skyCode.characters.count > 0 && skyDesc.characters.count > 0 && rainProb.characters.count > 0 && temp.characters.count > 0 else {break}
            
            weatherModel.inNhours!["\(hour)"] = [
                "skyCode":skyCode
                ,"skyDesc":skyDesc
                ,"rainProb":rainProb
//                ,"rainAmount":rainAmount
                ,"temp":temp
                ,"skyIcon":self.weatherIconFromCode(skyCode)]
        }
        
        return weatherModel
    }
    
    
    /**
     Get the Icon number of Weather from WeatherCode. 
     There are two versions of icon. One is for day times and the other is for night times.
     
     - parameter code: WeatherCode such as "SKY_S01"
     - returns: Icon which represents the weather.
     */
    func weatherIconFromCode(code:String) -> String {
        var iconName:String
        
        switch code {
        case "SKY_S00": iconName = "38"
        case "SKY_S07": iconName = "18"
        case "SKY_S08": iconName = "21"
        case "SKY_S09": iconName = "32"
        case "SKY_S10": iconName = "04"
        case "SKY_S11": iconName = "29"
        case "SKY_S12": iconName = "26"
        case "SKY_S13": iconName = "27"
        case "SKY_S14": iconName = "28"
            
        case "SKY_S01": iconName = NCDateManager().isDay ? "01" : "08"
        case "SKY_S02": iconName = NCDateManager().isDay ? "02" : "09"
        case "SKY_S03": iconName = NCDateManager().isDay ? "03" : "10"
        case "SKY_S04": iconName = NCDateManager().isDay ? "12" : "40"
        case "SKY_S05": iconName = NCDateManager().isDay ? "13" : "41"
        case "SKY_S06": iconName = NCDateManager().isDay ? "14" : "42"

        default: iconName = "38"
        }
        
        return iconName
    }
    
    /**
     Get the description and icon of Weather from WeatherCode
     
     - parameter strWeatherCode: WeatherCode such as "SKY_S01"
     - returns: weather Description and Icon such as ("맑음","1,8")
     */
//    func weatherNameAndIconFrom(strWeatherCode:String) -> (String,String) {
//        var weatherCode:WeatherCode
//        
//        switch strWeatherCode {
//        case "SKY_S00": weatherCode = .SKY_S00
//        case "SKY_S01": weatherCode = .SKY_S01
//        case "SKY_S02": weatherCode = .SKY_S02
//        case "SKY_S03": weatherCode = .SKY_S03
//        case "SKY_S04": weatherCode = .SKY_S04
//        case "SKY_S05": weatherCode = .SKY_S05
//        case "SKY_S06": weatherCode = .SKY_S06
//        case "SKY_S07": weatherCode = .SKY_S07
//        case "SKY_S08": weatherCode = .SKY_S08
//        case "SKY_S09": weatherCode = .SKY_S09
//        case "SKY_S10": weatherCode = .SKY_S10
//        case "SKY_S11": weatherCode = .SKY_S11
//        case "SKY_S12": weatherCode = .SKY_S12
//        case "SKY_S13": weatherCode = .SKY_S13
//        case "SKY_S14": weatherCode = .SKY_S14
//        default: weatherCode = .SKY_S00
//        }
//        
//        return (weatherCode.description,weatherCode.rawValue)
//    }
//    
//    // enum의 rawValue는 Tuple이 될 수 없어서 description을 사용하기로 함
//    enum WeatherCode:String, CustomStringConvertible {
//        case SKY_S00 = "38"
//        case SKY_S07 = "18"
//        case SKY_S08 = "21"
//        case SKY_S09 = "32"
//        case SKY_S10 = "4"
//        case SKY_S11 = "29"
//        case SKY_S12 = "26"
//        case SKY_S13 = "27"
//        case SKY_S14 = "28"
//        
//        // 해와 달을 구분
//        case SKY_S01 = "1,8"
//        case SKY_S02 = "2,9"
//        case SKY_S03 = "3,10"
//        case SKY_S04 = "12,40"
//        case SKY_S05 = "13,41"
//        case SKY_S06 = "14,42"
//        
//        var iconCode: String {
//            switch self {
//            case .SKY_S00: return "상태없음"
//            case .SKY_S01: return "맑음"
//            case .SKY_S02: return "구름조금"
//            case .SKY_S03: return "구름많음"
//            case .SKY_S04: return "구름많고 비"
//            case .SKY_S05: return "구름많고 눈"
//            case .SKY_S06: return "구름많고 비 또는 눈"
//            case .SKY_S07: return "흐림"
//            case .SKY_S08: return "흐리고 비"
//            case .SKY_S09: return "흐리고 눈"
//            case .SKY_S10: return "흐리고 비 또는 눈"
//            case .SKY_S11: return "흐리고 낙뢰"
//            case .SKY_S12: return "뇌우, 비"
//            case .SKY_S13: return "뇌우, 눈"
//            case .SKY_S14: return "뇌우, 비 또는 눈"
//            }
//        }
//        
//        var description: String {
//            switch self {
//            case .SKY_S00: return "상태없음"
//            case .SKY_S01: return "맑음"
//            case .SKY_S02: return "구름조금"
//            case .SKY_S03: return "구름많음"
//            case .SKY_S04: return "구름많고 비"
//            case .SKY_S05: return "구름많고 눈"
//            case .SKY_S06: return "구름많고 비 또는 눈"
//            case .SKY_S07: return "흐림"
//            case .SKY_S08: return "흐리고 비"
//            case .SKY_S09: return "흐리고 눈"
//            case .SKY_S10: return "흐리고 비 또는 눈"
//            case .SKY_S11: return "흐리고 낙뢰"
//            case .SKY_S12: return "뇌우, 비"
//            case .SKY_S13: return "뇌우, 눈"
//            case .SKY_S14: return "뇌우, 비 또는 눈"
//            }
//        }
//    }
}
