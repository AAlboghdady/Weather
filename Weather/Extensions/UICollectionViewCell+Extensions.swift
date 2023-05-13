//
//  UICollectionViewCell+Extensions.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit

extension UICollectionViewCell {
    
    static var cellId: String {
        return String(describing: self)
    }
    
    static var bundle: Bundle {
        return Bundle(for: self)
    }
    
    static var nib: UINib {
        return UINib(nibName:  self.cellId, bundle: self.bundle)
    }
    
    static func register(with collectionView: UICollectionView) {
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }
}
