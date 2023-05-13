//
//  ApiManager.swift
//  MVVM-C
//
//  Created by Abdurrahman Alboghdady on 09/04/2022.
//

import Moya
import Alamofire

enum ApiManager {
    case currentWeather(lat: Double?, long: Double?, cityName: String?, zipCode: String?)
    case forecast(lat: Double?, long: Double?, cityName: String?, zipCode: String?)
}

// MARK: - TargetType Protocol Implementation
extension ApiManager: TargetType {
    var baseURL: URL {
        return URL(string: Constants.APIURL)!
    }
    
    var path: String {
        switch self {
        case .currentWeather:
            return "weather"
        case .forecast:
            return "forecast"
        }
    }
    
    var parameters: [String: Any]? {
        var params = [String : Any]()
        switch self {
        case .currentWeather(let lat, let long, let cityName, let zipCode),
                .forecast(let lat, let long, let cityName, let zipCode):
            if lat != nil {
                params["lat"] = lat
            }
            if long != nil {
                params["lon"] = long
            }
            if cityName != nil {
                params["q"] = cityName
            }
            if zipCode != nil {
                params["zip"] = zipCode
            }
        }
        params["appid"] = Constants.APIKey
        return params
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        return JSONEncoding.default
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.queryString)
    }
    
    var headers: [String: String]? {
        return [:]
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var manager: Data {
        return Data()
    }
}
