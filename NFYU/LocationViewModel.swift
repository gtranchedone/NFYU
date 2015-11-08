//
//  ForecastViewModel.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 06/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

enum CellIdentifiers: String {
    case ForecastCell = "LocationCell"
}

// This view model isn't exactly of the kind preached by the standard MVVM pattern
// I think of view models as the objects responsible for providing the right, formatted, view for a model to a controller
// This means that this object is reponsible for taking a model and format the information for display, pass it to a view, and return the view to the caller
// The benefit is that the controller doesn't know about the view and the details of how to format the data for displaying and therefore, the app could use
// the same controller with different views for the same model without the controller noticing
protocol LocationViewModelProtocol {
    
    func collectionViewCellForLocation(location: Location, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell
    
}

class LocationViewModel: LocationViewModelProtocol {
    
    func collectionViewCellForLocation(location: Location, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = CellIdentifiers.ForecastCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationCollectionViewCell
        let forecast = location.forecasts.first
        if let forecast = forecast {
            cell.currentTemperatureLabel.text = "\(forecast.currentTemperature)º"
        }
        else {
            cell.currentTemperatureLabel.text = "-º"
        }
        cell.weatherConditionLabel.text = forecast?.weather.localizedDescription ?? "-"
        cell.locationNameLabel.text = location.city ?? "-"
        return cell
    }
    
}
