//
//  InfoPostingVC.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/14/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class InfoPostingVC: UIViewController {
    
    var locationName: String!
    var locationCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingState(isLoading: false)
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToShare" {
            let detailsController = segue.destination as! ShareVC
            detailsController.locationName = locationName
            detailsController.locationCoordinates = locationCoordinates
            
            detailsController.mediaURL = linkTextField.text ?? ""
        }
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocation(_ sender: Any) {
        showLoadingState(isLoading: true)
        guard let locationName = locationTextField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty
            else {
                alert(title: "Warning", message: "You must provide a location")
                showLoadingState(isLoading: false)
                return
        }
        
        getCoordinates(location: locationName) { (locationCoordinates, error) in
            if error != nil {
                self.alert(title: "ERROR", message: "Try another place.")
                self.showLoadingState(isLoading: false)
                return
            }
            self.showLoadingState(isLoading: false)
            
            DispatchQueue.main.async {
                self.locationName = locationName
                self.locationCoordinates = locationCoordinates
                self.performSegue(withIdentifier: "goToShare", sender: self)
            }
        }
    }
    
    func getCoordinates(location: String, completion: @escaping (_ locationCoordicates: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    func showLoadingState(isLoading: Bool) {
        DispatchQueue.main.async {
            self.locationTextField.isUserInteractionEnabled = !isLoading
            self.linkTextField.isUserInteractionEnabled = !isLoading
            self.findLocationButton.isEnabled = !isLoading
            
            if isLoading {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
}
