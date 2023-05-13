//
//  ForecastViewModel.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 13/05/2023.
//

import RxSwift
import RxCocoa
import GRDB

class ForecastViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    private var forecastBehavior = BehaviorRelay<[Weather]>(value: [])
    private var forecastNext24HoursBehavior = BehaviorRelay<[Weather]>(value: [])
    private var forecastNext48HoursBehavior = BehaviorRelay<[Weather]>(value: [])
    
    private var forecastSubject = PublishSubject<[Weather]>()
    var forecastObservable: Observable<[Weather]> {
        return forecastSubject
    }
    
    private var errorMessageSubject = PublishSubject<String>()
    var errorMessageObservable: Observable<String> {
        return errorMessageSubject
    }
    
    func loadCurrentWeather(lat: Double?, long: Double?, cityName: String?, zipCode: String?) {
        loadingBehavior.accept(true)
        let api = ApiManager.forecast(lat: lat, long: long, cityName: cityName, zipCode: zipCode)
        NetworkRequest.shared.sendRequest(function: api, model: Forecast.self) { [weak self] response in
            self?.loadingBehavior.accept(false)
            guard let self = self else { return }
            self.handle(response: response)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            print(error)
            self.errorMessageSubject.onNext(error)
        }
    }
    
    func handle(response: Forecast) {
        var allNewWeatherArray = [Weather]()
        var newWeatherArrayNext24Hours = [Weather]()
        var newWeatherArrayNext48Hours = [Weather]()
        guard let list = response.list else { return }
        for i in 0..<list.count {
            guard let time = list[i].dt_txt?.components(separatedBy: " ").last,
                  let temp = list[i].main?.temp,
                  let weather = list[i].weather?.first else { continue }
            var newWeather = weather
            newWeather.city = time
            newWeather.temp = temp
            allNewWeatherArray.append(newWeather)
            if i < 8 {
                // get the next 24 hours only
                newWeatherArrayNext24Hours.append(newWeather)
            }
            if i < 16 {
                // get the next 48 hours only
                newWeatherArrayNext48Hours.append(newWeather)
            }
        }
        forecastSubject.onNext(newWeatherArrayNext24Hours)
        forecastBehavior.accept(allNewWeatherArray)
        forecastNext24HoursBehavior.accept(newWeatherArrayNext24Hours)
        forecastNext48HoursBehavior.accept(newWeatherArrayNext48Hours)
        
            guard let weather = allNewWeatherArray.first,
                  let city = response.city?.name,
                  let temp = response.list?.first?.main?.temp else { return }
        save(weather: weather, city: city, temp: temp)
    }
    
    func filterBy(next: FilterHours) {
        switch next {
        case .hours24:
            forecastSubject.onNext(forecastNext24HoursBehavior.value)
        case .hours48:
            forecastSubject.onNext(forecastNext48HoursBehavior.value)
        }
    }

    func save(weather: Weather, city: String, temp: Double) {
        var newWeather = weather
        newWeather.city = city
        newWeather.temp = temp
        // check if the weather are stored in the database first
        AppDatabase.shared.getAllWeatherFromDataBase { [weak self] weatherArray in
            guard let self = self else { return }
            if weatherArray.count == 10 {
                // save only 10 records
                var newWeatherArray = weatherArray
                newWeatherArray = Array(weatherArray.dropFirst())
                newWeatherArray.append(newWeather)
                self.forecastSubject.onNext(newWeatherArray)
                self.removeAllWeatherToDataBase()
                DispatchQueue.global(qos: .background).async {
                    for weather in newWeatherArray {
                        self.saveWeatherToDataBase(weather: weather)
                    }
                }
            } else {
                self.saveWeatherToDataBase(weather: newWeather)
                AppDatabase.shared.getAllWeatherFromDataBase { weatherArray in
                    self.forecastSubject.onNext(weatherArray)
                }
                var newWeatherArray = weatherArray
                newWeatherArray.append(newWeather)
            }
        }
    }
    
    func saveWeatherToDataBase(weather: Weather) {
        var weather = weather
        DispatchQueue.global(qos: .background).async {
            // saving weather to the database
            try! AppDatabase.shared.saveWeather(&weather)
        }
    }
    
    func removeAllWeatherToDataBase() {
        DispatchQueue.global(qos: .background).async {
            // remove all weather from the database
            try! AppDatabase.shared.removeAllWeather()
        }
    }
}

enum FilterHours {
    case hours24
    case hours48
}
