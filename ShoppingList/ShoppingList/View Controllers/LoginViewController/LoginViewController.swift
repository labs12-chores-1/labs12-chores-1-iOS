//
//  LoginViewController.swift
//  ShoppingList
//
//  Created by Jason Modisett on 2/14/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import Auth0
import SwiftKeychainWrapper
import SimpleKeychain

class LoginViewController: UIViewController, StoryboardInstantiatable {
    
    static let storyboardName: StoryboardName = "LoginViewController"
    let credentialsManager = CredentialsManager.init(authentication: Auth0.authentication())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        showLogin()
    }
    
    func showLogin() {
        guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://" + clientInfo.domain + "/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let credentials):
                    guard let accessToken = credentials.accessToken,
                        let idToken = credentials.idToken else { return }
                    
                    SessionManager.tokens = Tokens(accessToken: accessToken, idToken: idToken)
                    UI {
                        UIApplication.shared.keyWindow?.rootViewController = MainViewController.instantiate()
                    }
                }
        }
    }
    
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
        guard
            let path = bundle.path(forResource: "Auth0", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {
                print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
                return nil
        }
        
        guard
            let clientId = values["ClientId"] as? String,
            let domain = values["Domain"] as? String
            else {
                print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
                print("File currently has the following entries: \(values)")
                return nil
        }
        return (clientId: clientId, domain: domain)
    }
}

