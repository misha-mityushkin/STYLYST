//
//  TabBarController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = UserDefaults.standard.string(forKey: K.UserDefaultKeys.email), let password = UserDefaults.standard.string(forKey: K.UserDefaultKeys.password), !email.isEmpty, !password.isEmpty {
            
			if let profileNavVC = self.viewControllers?.last as? UINavigationController {
				(profileNavVC.viewControllers[0] as? SignInViewController)?.spinnerView.create(parentVC: profileNavVC.viewControllers[0] as? SignInViewController ?? self)
			}
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                
                if error == nil {
                    if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: K.Storyboard.profileVC) as? ProfileViewController, let profileNavController = self.viewControllers?.last as? UINavigationController {
                        
                        print("root controller set")
                        profileNavController.viewControllers[0] = profileVC
                        profileNavController.popToRootViewController(animated: false)
                    }
                }
            }
        }
    }
}
