//
//  DashboardVC.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit
import RxSwift
import RxCocoa

class DashboardVC: UIViewController {

    @IBOutlet weak var searchedLocationView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: DashboardViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        subscribeToLoading()
        subscribeToSearchedLocations()
        subscribeToErrorMessage()
        subscribeToWeather()
        
//        viewModel.loadCurrentWeather(lat: nil, long: nil, cityName: "Riyadh", zipCode: nil)
        viewModel.getAllWeatherFromDataBase()
    }
    
    func setupViews() {
        WeatherCell.register(with: collectionView)
    }
    
    func subscribeToLoading() {
        viewModel.loadingBehavior.subscribe { [weak self] (isLoading) in
            self?.showLoading(isLoading)
        }.disposed(by: disposeBag)
    }
    
    func subscribeToSearchedLocations() {
        viewModel.noSearchedLocationsBehavior.subscribe { [weak self] (noSearchedLocations) in
            if noSearchedLocations {
                self?.searchedLocationView.isHidden = true
            }
        }.disposed(by: disposeBag)
    }
    
    func subscribeToErrorMessage() {
        viewModel.errorMessageObservable.subscribe { [weak self] (error) in
            self?.showErrorAlert(title: error)
        }.disposed(by: disposeBag)
    }
    
    func subscribeToWeather() {
        // collectionView cells
        viewModel.weatherObservable.asObservable()
            .bind(to: collectionView
                    .rx
                .items(cellIdentifier: "\(WeatherCell.self)",
                           cellType: WeatherCell.self)) { _, item, cell in
                cell.configure(weather: item)
            }
            .disposed(by: disposeBag)
        // collectionView model selected
        collectionView.rx.modelSelected(Weather.self)
            .subscribe(onNext: { item in
//                AppCoordinator.shared.goToTeams(league: league)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func currentWeatherPressed(_ sender: Any) {
    }
    
    @IBAction func forcastPressed(_ sender: Any) {
        AppCoordinator.shared.goToForecast()
    }
}
