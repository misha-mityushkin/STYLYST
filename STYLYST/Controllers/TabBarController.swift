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
        
        if let uid = UserDefaults.standard.string(forKey: K.UserDefaultKeys.uid), let password = UserDefaults.standard.string(forKey: K.UserDefaultKeys.password), !uid.isEmpty, !password.isEmpty {
            
            let db = Firestore.firestore()
            let userRef = db.collection(K.FirebaseCollectionNames.users).document(uid)
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let passwordInFirestore = document.get(K.UserDefaultKeys.password) as? String, !passwordInFirestore.isEmpty, passwordInFirestore == password {
                        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: K.Storyboard.profileVC) as? ProfileViewController, let profileNavController = self.viewControllers?.last as? UINavigationController {
                            
                            print("root controller set")
                            profileNavController.viewControllers[0] = profileVC
                            profileNavController.popToRootViewController(animated: false)
                        }
                    }
                }
            }
            
        }

        //let profileNavController = tabBarController?.viewControllers?.last as? ProfileNavigationController
        
        
        // Do any additional setup after loading the view.
    }

}
