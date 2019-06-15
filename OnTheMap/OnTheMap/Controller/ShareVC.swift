//
//  ShareVC.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/14/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ShareVC: UIViewController {
    
    var locationName: String!
    var locationCoordinates: CLLocationCoordinate2D!
    var mediaURL: String!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinates!
        annotation.title = UdacityAPI.firstName + " " + UdacityAPI.lastName
        annotation.subtitle = mediaURL
        mapView.addAnnotation(annotation)
        
        let limitedViewRegion = MKCoordinateRegion(center: locationCoordinates!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(limitedViewRegion, animated: false)
    }
    
    @IBAction func finish(_ sender: Any) {
        
        UdacityAPI.postStudentLocation(mapString: locationName, mediaURL: mediaURL, locationCoordinates: locationCoordinates) { (error) in
            if error != nil {
                self.alert(title: "ERROR", message: "Somethion went wrong, try again later.")
                return
            }
            UserDefaults.standard.set(self.locationName, forKey: "studentLocation")
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
}

extension ShareVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinId") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinId")
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
