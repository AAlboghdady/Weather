//
//  AppCoordinator.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit

class AppCoordinator: Coordinator {
    
    static let shared = AppCoordinator(navigationController: UINavigationController())
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // launch leagues view controller
        goToDashboard()
    }
    
    func goToDashboard() {
        // Instantiate DashboardVC
        let vc = DashboardVC()
        // Instantiate ViewModel
        let vm = DashboardViewModel()
        // Set the ViewModel to ViewController
        vc.viewModel = vm
        vc.title = "Dashboard"
        // Push it.
        navigationController.pushViewController(vc, animated: true)
        Constants.window?.rootViewController = navigationController
        Constants.window?.makeKeyAndVisible()
    }
    
    func goToForecast() {
        // Instantiate ForecastVC
        let vc = ForecastVC()
        // Instantiate ViewModel
        let dashboardViewModel = DashboardViewModel()
        // Set the ViewModel to ViewController
        let forecastViewModel = ForecastViewModel()
        // Set the ViewModel to ViewController
        vc.weatherViewModel = dashboardViewModel
        vc.forecastViewModel = forecastViewModel
        vc.title = "Forecast"
        // Push it.
        navigationController.pushViewController(vc, animated: true)
    }
}
