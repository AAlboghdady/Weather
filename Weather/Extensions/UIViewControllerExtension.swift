//
//  UIViewControllerExtension.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit
import ProgressHUD

extension UIViewController {
    func showErrorAlert(title: String) {
        let alert = UIAlertController(title: "Error", message: title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoading(_ bool: Bool) {
        if bool {
            ProgressHUD.show()
        } else {
            ProgressHUD.dismiss()
        }
    }
    
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
}
