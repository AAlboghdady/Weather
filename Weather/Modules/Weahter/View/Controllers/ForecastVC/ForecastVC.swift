//
//  ForecastVC.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 13/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class ForecastVC: UIViewController {

    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var latTF: UITextField!
    @IBOutlet weak var longTF: UITextField!
    @IBOutlet weak var searchedLocationView: UIStackView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var lastSearchedCollectionView: UICollectionView!
    @IBOutlet weak var filterByNextHoursButton: UIButton!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    var weatherViewModel: DashboardViewModel!
    var forecastViewModel: ForecastViewModel!
    let disposeBag = DisposeBag()
    var searchBy: SearchBy = .city
    let locationManager = CLLocationManager()
    var currentLat = 0.0
    var currentLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        subscribeToLoading()
        subscribeToSearchedLocations()
        subscribeToErrorMessage()
        subscribeToWeather()
        subscribeToForecast()
        
        weatherViewModel.getAllWeatherFromDataBase()
        
        showSearchBy(index: 0)
    }
    
    func setupViews() {
        WeatherCell.register(with: lastSearchedCollectionView)
        WeatherCell.register(with: forecastCollectionView)
        filterByNextHoursButton.isHidden = true
    }
    
    func subscribeToLoading() {
        forecastViewModel.loadingBehavior.subscribe { [weak self] (isLoading) in
            self?.showLoading(isLoading)
        }.disposed(by: disposeBag)
    }
    
    func subscribeToSearchedLocations() {
        weatherViewModel.noSearchedLocationsBehavior.subscribe { [weak self] (noSearchedLocations) in
            if noSearchedLocations {
                self?.searchedLocationView.isHidden = true
            }
        }.disposed(by: disposeBag)
    }
    
    func subscribeToErrorMessage() {
        weatherViewModel.errorMessageObservable.subscribe { [weak self] (error) in
            self?.showErrorAlert(title: error)
        }.disposed(by: disposeBag)
    }
    
    func subscribeToWeather() {
        // collectionView cells
        weatherViewModel.weatherObservable.asObservable()
            .bind(to: lastSearchedCollectionView
                    .rx
                .items(cellIdentifier: "\(WeatherCell.self)",
                           cellType: WeatherCell.self)) { _, item, cell in
                cell.configure(weather: item)
            }
            .disposed(by: disposeBag)
        // collectionView model selected
        lastSearchedCollectionView.rx.modelSelected(Weather.self)
            .subscribe(onNext: { item in
//                AppCoordinator.shared.goToTeams(league: league)
            })
            .disposed(by: disposeBag)
    }
    
    func subscribeToForecast() {
        // collectionView cells
        forecastViewModel.forecastObservable.asObservable()
            .bind(to: forecastCollectionView
                    .rx
                .items(cellIdentifier: "\(WeatherCell.self)",
                           cellType: WeatherCell.self)) { [weak self] _, item, cell in
                cell.configure(weather: item)
                if self?.filterByNextHoursButton.isHidden ?? true {
                    self?.filterByNextHoursButton.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        // collectionView model selected
        forecastCollectionView.rx.modelSelected(Weather.self)
            .subscribe(onNext: { item in
//                AppCoordinator.shared.goToTeams(league: league)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func searchBy(_ sender: UISegmentedControl) {
        showSearchBy(index: sender.selectedSegmentIndex)
    }
    
    func showSearchBy(index: Int) {
        cityTF.isHidden = true
        zipTF.isHidden = true
        latTF.isHidden = true
        longTF.isHidden = true
        searchButton.isHidden = false
        switch index {
        case 0:
            // city name
            cityTF.isHidden = false
            searchBy = .city
        case 1:
            // zip code
            zipTF.isHidden = false
            searchBy = .zip
        case 2:
            // lat and long
            latTF.isHidden = false
            longTF.isHidden = false
            searchBy = .location
        case 3:
            // current location
            searchButton.isHidden = true
            self.getCurrentLocation()
            searchBy = .currentLocation
        default:
            break
        }
    }
    
    func getCurrentLocation() {
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func search(_ sender: Any) {
        switch searchBy {
        case .city:
            forecastViewModel.loadCurrentWeather(lat: nil, long: nil, cityName: cityTF.text!, zipCode: nil)
        case .zip:
            forecastViewModel.loadCurrentWeather(lat: nil, long: nil, cityName: nil, zipCode: zipTF.text!)
        case .location:
            let lat = Double(latTF.text ?? "0.0")
            let long = Double(longTF.text ?? "0.0")
            forecastViewModel.loadCurrentWeather(lat: lat, long: long, cityName: nil, zipCode: nil)
        case .currentLocation:
            // TODO: - get current location first
            forecastViewModel.loadCurrentWeather(lat: currentLat, long: currentLong, cityName: nil, zipCode: nil)
        }
    }
    
    @IBAction func filterByNextHours(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setTitle("24 hours", for: .normal)
            forecastViewModel.filterBy(next: .hours48)
        } else {
            sender.tag = 0
            sender.setTitle("48 hours", for: .normal)
            forecastViewModel.filterBy(next: .hours24)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ForecastVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            return
        default:
            break
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLat = location.coordinate.latitude
        currentLong = location.coordinate.longitude
        forecastViewModel.loadCurrentWeather(lat: currentLat, long: currentLong, cityName: nil, zipCode: nil)
        locationManager.stopUpdatingLocation()
    }
}

enum SearchBy {
    case city
    case zip
    case location
    case currentLocation
}
