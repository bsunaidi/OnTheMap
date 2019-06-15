//
//  MapVC.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/14/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    var studentsLocations: [StudentLocation]! {
        return StudentLocationModel.shared.studentsLocations
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (studentsLocations == nil) ? refreshStudentsLocations(self) : DispatchQueue.main.async {self.updatePointAnnotations()}
    }
    
    
    @IBAction func addPin(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "studentLocation") != nil {
            let alert = UIAlertController(title: "You have been already posted your location. Do you want to post it again?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Post", style: .destructive, handler: { (action) in self.performSegue(withIdentifier: "addPin", sender: self)
            }))
            present(alert, animated: true, completion: nil)
            
        }
        else {
            self.performSegue(withIdentifier: "addPin", sender: self)
        }
    }
    
    
    @IBAction func refreshStudentsLocations(_ sender: Any) {
        UdacityAPI.getStudentsLocations { (_, error) in
            if error != nil {
                self.alert(title: "ERROR", message: "Somthing went wrong!")
                return
            }
            DispatchQueue.main.async {
                self.updatePointAnnotations()
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        UdacityAPI.deleteSession { (error) in
            if let error = error {
                self.alert(title: "ERROR", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.updatePointAnnotations()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func updatePointAnnotations() {
        var pointAnnotations = [MKPointAnnotation]()
        
        for studentLocation in studentsLocations {
            let latitude = CLLocationDegrees(studentLocation.latitude ?? 0)
            let longitude = CLLocationDegrees(studentLocation.longitude ?? 0)
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let firstName = studentLocation.firstName ?? ""
            let lastName = studentLocation.lastName ?? ""
            let mediaURL = studentLocation.mediaURL ?? ""
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            if !mapView.annotations.contains(where: {$0.title == annotation.title}){
                pointAnnotations.append(annotation)
            }
        }
        print("The newest point annotations are equal to: ", pointAnnotations.count)
        mapView.addAnnotations(pointAnnotations)
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let openIt = view.annotation?.subtitle!, let url = URL(string: openIt) else {return}
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
