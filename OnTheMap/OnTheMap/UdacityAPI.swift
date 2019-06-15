//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 5/29/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ARKit


class UdacityAPI {
    
    static var uniqueKey = ""
    static var firstName = ""
    static var lastName = ""
    
    static func checkError(error: Error?, response: URLResponse?) -> String? {
        if error != nil {
            return error?.localizedDescription
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
            return statusCodeError.localizedDescription
        }
        
        guard statusCode >= 200 && statusCode < 300 else {
            var errorMessage = ""
            switch statusCode {
            case 400:
                errorMessage = "Bad Request"
            case 401:
                errorMessage = "Invalid Credentials"
            case 403:
                errorMessage = "Unauthorized"
            case 405:
                errorMessage = "HTTP Method Not Allowed"
            case 410:
                errorMessage = "URL Changed"
            case 500:
                errorMessage = "Server Error"
            default:
                errorMessage = "Try Again"
            }
            return errorMessage
        }
        return nil
    }
    
    static func postSession (email: String, password: String, completion: @escaping (String?) -> ()) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            let result = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            if let resultError = result["error"] as? String {
                completion(resultError)
                return
            }
            
            let dict = result ["account"] as! [String: Any]
            let uniqueKey = dict ["key"] as? String ?? "33106441896"
            UdacityAPI.uniqueKey = uniqueKey
            completion(nil)
        }
        task.resume()
    }
    
    static func deleteSession (completion: @escaping (Error?) -> () ) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completion(error)
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    static func postStudentLocation(mapString: String, mediaURL: String, locationCoordinates: CLLocationCoordinate2D, completion: @escaping (Error?) -> () ) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(UdacityAPI.uniqueKey)\", \"firstName\": \"\(UdacityAPI.firstName)\", \"lastName\": \"\(UdacityAPI.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(locationCoordinates.latitude), \"longitude\": \(locationCoordinates.longitude)}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completion(error)
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            completion(nil)
        }
        task.resume()
    }
    
    static func getStudentsLocations(completion: @escaping ([StudentLocation]?, String?) -> ()) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt")!)
        request.httpMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let errorMessage = checkError(error: error, response: response) {
                completion (nil, errorMessage)
                    return
                }
            
            let jsonDict = try! JSONSerialization.jsonObject(with: data!, options:[]) as! [String:Any]
            
            guard let outcomes = jsonDict ["results"] as? [[String:Any]] else {return}
            
            let outcomesData = try! JSONSerialization.data(withJSONObject: outcomes, options: .prettyPrinted)
            let studentsLocations = try! JSONDecoder().decode([StudentLocation].self, from: outcomesData)
            StudentLocationModel.shared.studentsLocations = studentsLocations
            completion(studentsLocations, nil)
        }
        task.resume()
    }
    
    static func getPublicUserData(completion: @escaping (String?) -> ()) {
        let url = URL(string: "https://onthemap-api.udacity.com/v1/users/\(UdacityAPI.uniqueKey)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            let subdata = data![5..<data!.count]
            guard let dictionary = try? JSONSerialization.jsonObject(with: subdata, options: []) as? [String : Any] else {
                completion("Result is nil or could not be cast to [String:Any]")
                return
            }
            
            UdacityAPI.firstName = dictionary["first_name"] as? String ?? ""
            UdacityAPI.lastName = dictionary["last_name"] as? String ?? ""
            completion(nil)
            }.resume()
    }
}

