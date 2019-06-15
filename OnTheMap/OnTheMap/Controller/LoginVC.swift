//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Bushra AlSunaidi on 5/26/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        showLoadingState(isLoading: false)
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else {
            print ("The URL is Invalid")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func logIn(_ sender: Any) {
        view.endEditing(true)
        showLoadingState(isLoading: true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty, !password.isEmpty
            else {
                alert(title: "Warning", message: "Please fill your email/password before log in")
                showLoadingState(isLoading: false)
                return
        }
        
        
        
        UdacityAPI.postSession(email: email, password: password) { (error) in
            
            if error != nil {
                self.showLoadingState(isLoading: false)
                self.alert(title: "ERROR", message: error!)
                return
            }
            
            UdacityAPI.getPublicUserData { error in
                self.showLoadingState(isLoading: false)
                if error != nil {
                    self.alert(title: "ERROR", message: error!)
                    return
                }
                
                DispatchQueue.main.async {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: "showTapVC", sender: self)
                }
            }
        }
    }
    
    func showLoadingState(isLoading: Bool) {
        DispatchQueue.main.async {
            self.emailTextField.isUserInteractionEnabled = !isLoading
            self.passwordTextField.isUserInteractionEnabled = !isLoading
            self.logInButton.isEnabled = !isLoading
            
            if isLoading {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func handleLoginResponse (error: Error?) {
        if let error = error as? URLError, error.code == URLError.Code.notConnectedToInternet {
            alert(title: "ERROR", message: "The Internet connection is offline")
            showLoadingState(isLoading: false)
        }
    }
}
