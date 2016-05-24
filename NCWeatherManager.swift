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

    // MARK: - 날씨API요청
    
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
//                print("Success with JSON: \(JSON)")
                
                guard let weatherModel = self.makeWeatherModel(JSON) where completion != nil else {return}
                completion!(weatherModel)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }

        }
    }
    
    // MARK: - 날씨API 파싱 도우미메소드
    
    /**
     Make WeatherModel using the result of SK Planet WeatherAPI.
     
     - parameter JSON: result of SK Planet WeatherAPI
     - returns: WeatherModel made by JSON or nil if error occured while parsing.
     */
    private func makeWeatherModel(JSON:AnyObject) -> NCWeatherModel? {
        
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
        
        return weatherModel
    }
    
    private func makeValidWeatherModel(skyTemp sky: [String:AnyObject], rainModel rain: [String:AnyObject], tempModel temp: [String:AnyObject]) -> NCWeatherModel{
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
    private func weatherIconFromCode(code:String) -> String {
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
            
        // 낮 시간에는 해 아이콘, 밤 시간에는 달 아이콘을 리턴
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
}
