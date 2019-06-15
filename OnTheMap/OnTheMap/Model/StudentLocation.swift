//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/10/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation

struct StudentLocation: Codable {
    
    let objectId: String?
    let uniqueKey: String?
    let firstName : String?
    let lastName : String?
    let mapString : String?
    let mediaURL : String?
    let latitude : Double?
    let longitude : Double?
    let createdAt: String?
    let updatedAt : String?
}
