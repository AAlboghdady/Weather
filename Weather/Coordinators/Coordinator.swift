//
//  Coordinator.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit

protocol Coordinator {
    var navigationController : UINavigationController { get set }
    
    func start()
}
