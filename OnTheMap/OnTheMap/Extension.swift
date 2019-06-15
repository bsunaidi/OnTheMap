//
//  Extension.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 6/14/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert (title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
