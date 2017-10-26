//
//  UserDefaultUtils.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 26/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit



extension UserDefaults {
    
    public func isFirstLaunch() -> Bool {
        return value(forKey: "firstTimeLaunch") as? Bool ?? true
    }
    
    public func doFirstLaunch() -> UIAlertController {
        /*
         * In preferences, firstTimeLaunch is not set (or true).
         * We set it at false.
         * We create an alert view returned to the calling class.
         */
        // Set preferences
        UserDefaults.standard.set(false, forKey: "firstTimeLaunch")
        
        // Create an alert view with welcoming message
        let alertFirstLaunchController = UIAlertController(title: "Arrivée", message: "Bienvenue dans votre nouvelle appli ! Utile pour gérer ses contacts", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
        }
        alertFirstLaunchController.addAction(okAction)
        // Return the Alert controller to show it in calling ViewController
        return alertFirstLaunchController
    }
}
