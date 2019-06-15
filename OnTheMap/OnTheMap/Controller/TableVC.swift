//
//  TableVC.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/14/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TableVC: UITableViewController {
    
    let tableCellId = "tableCellId"
    
    var studentsLocations: [StudentLocation]! {
        return StudentLocationModel.shared.studentsLocations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (studentsLocations == nil) ? refreshStudentsLocations(self) : DispatchQueue.main.async {self.tableView.reloadData()}
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
                self.tableView.reloadData()
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
                self.tableView.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsLocations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellId, for: indexPath)
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = studentsLocations[indexPath.row].firstName
        cell.detailTextLabel?.text = studentsLocations[indexPath.row].mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentsLocations[indexPath.row]
        guard let openIt = studentLocation.mediaURL, let url = URL(string: openIt) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil )
}

}
