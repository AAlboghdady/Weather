//
//  DashboardViewModel.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import RxSwift
import RxCocoa
import GRDB

class DashboardViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    var noSearchedLocationsBehavior = BehaviorRelay<Bool>(value: false)
    
    private var weatherSubject = PublishSubject<[Weather]>()
    var weatherObservable: Observable<[Weather]> {
        return weatherSubject
    }
    
    private var errorMessageSubject = PublishSubject<String>()
    var errorMessageObservable: Observable<String> {
        return errorMessageSubject
    }
    
    func getAllWeatherFromDataBase() {
        AppDatabase.shared.getAllWeatherFromDataBase { [weak self] weatherArray in
            if weatherArray.isEmpty {
                self?.noSearchedLocationsBehavior.accept(true)
                return
            }
            self?.weatherSubject.onNext(weatherArray)
        }
    }
}
