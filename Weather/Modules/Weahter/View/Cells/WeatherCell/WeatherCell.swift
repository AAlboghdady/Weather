//
//  WeatherCell.swift
//  Weather
//
//  Created by Abdurrahman Alboghdady on 09/05/2023.
//

import UIKit
import Nuke

class WeatherCell: UICollectionViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(weather: Weather) {
        cityLabel.text = weather.city
        tempLabel.text = "\(weather.temp ?? 0.0)"
        guard let url = URL(string: Constants.imageURL + (weather.icon ?? "") + ".png") else { return }
        Nuke.loadImage(with: url, into: weatherImageView)
    }
}
