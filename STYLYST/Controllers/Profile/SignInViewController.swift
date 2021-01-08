//
//  SignInViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    var textFields: [UITextField] = []
    var textFieldsHoldAlert = [false, false]
	
	let destinationRegister = "register"
	let destinationContinueRegister = "continueRegister"
	var destination: String? //possible values: register, continueRegister, businessRegister
    
    var spinnerView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        textFields = [emailTextField, passwordTextField]
        for textField in textFields {
            textField.delegate = self
        }
        UITextField.format(textFields: textFields, height: 40, padding: 10)
        let passwordIcon: UIImage
        if #available(iOS 13.0, *) {
			passwordIcon = UIImage(systemName: K.ImageNames.eyeSlash)!
        } else {
            passwordIcon = UIImage(named: K.ImageNames.eyeSlash)!
        }
        passwordTextField.setRightViewButton(icon: passwordIcon, width: passwordTextField.frame.height * 1.05, height: passwordTextField.frame.height * 0.7, parentVC: self, action: #selector(self.showHidePassword(_:)))
        
        
        hideKeyboardWhenTappedAround()
        
        
        if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.sentVerificationCode) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.finishedRegistration) {
            
            if let verificationID = UserDefaults.standard.string(forKey: K.UserDefaultKeys.verificationID), !verificationID.isEmpty {
                Alerts.showTwoOptionAlert(title: "You have an ongoing registration process", message: "Tap continue to complete your registration", option1: "Continue", option2: "Cancel", sender: self, handler1: { (action1) in
					
					self.destination = self.destinationContinueRegister
					self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
                    //self.performSegue(withIdentifier: K.Segues.signInToFinishRegister, sender: self)
					
                }, handler2: nil)
            } else {
                Alerts.showTwoOptionAlert(title: "It appears you have began the registration process", message: "Due to an unknown error we will need to go through the registration process from the beginning", option1: "Continue", option2: "Cancel", sender: self, handler1: { (action1) in
                    
					self.destination = self.destinationRegister
					self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
                    //self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
                    
                }, handler2: nil)
            }
            
        }
        
        
        
        
        if let email = UserDefaults.standard.string(forKey: K.UserDefaultKeys.email), !email.isEmpty {
            emailTextField.text = email
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        var nonAlteredTextFields: [UITextField] = []
        for i in 0..<textFieldsHoldAlert.count {
            if !textFieldsHoldAlert[i] {
                nonAlteredTextFields.append(textFields[i])
            }
        }
        UITextField.formatBackground(textFields: textFields, height: 40, padding: 10)
        UITextField.formatPlaceholder(textFields: nonAlteredTextFields, height: 40, padding: 10)
    }
    
    
	@IBAction func registerButtonTapped(_ sender: UIButton) {
		destination = destinationRegister
		self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)	}
	
	
    @IBAction func signInPressed(_ sender: UIButton) {
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            if let password = passwordTextField.text, !password.isEmpty {
                
                signInButton.isUserInteractionEnabled = false
                hideKeyboard()
                spinnerView.create(parentVC: self)
				self.spinnerView.label.text = "Signing in..."
                
                Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                    if error == nil {
                        if let user = authResult?.user {
                            let db = Firestore.firestore()
                            let docRef = db.collection(K.Firebase.CollectionNames.users).document(user.uid)
                            docRef.getDocument { (document, error) in
                                
                                if let document = document, document.exists, error == nil {
                                    let firstName = document.get(K.Firebase.UserFieldNames.firstName) as? String
                                    let lastName = document.get(K.Firebase.UserFieldNames.lastName) as? String
                                    let phoneNumber = document.get(K.Firebase.UserFieldNames.phoneNumber) as? String
                                    let uid = user.uid
                                    
                                    Helpers.addUserToUserDefaults(firstName: firstName ?? "", lastName: lastName ?? "", email: email, phoneNumber: phoneNumber ?? "" , password: password, uid: uid )
                                    
                                    self.signInButton.isUserInteractionEnabled = true
                                    self.spinnerView.remove()
                                    UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.isSignedIn)
                                    self.performSegue(withIdentifier: K.Segues.signInToProfile, sender: self)
                                } else {
                                    self.signInButton.isUserInteractionEnabled = true
                                    self.spinnerView.remove()
                                    self.passwordTextField.text = ""
                                    Alerts.showNoOptionAlert(title: "Error signing in", message: "Restart the app, check your internet connection, and try again", sender: self)
                                }
                            }
                        } else {
                            self.signInButton.isUserInteractionEnabled = true
                            self.spinnerView.remove()
                            self.passwordTextField.text = ""
                            Alerts.showNoOptionAlert(title: "Error signing in", message: "Restart the app, check your internet connection, and try again", sender: self)
                        }
                    } else {
                        self.signInButton.isUserInteractionEnabled = true
                        self.spinnerView.remove()
                        self.passwordTextField.text = ""
                        self.passwordTextField.changePlaceholderText(to: "Incorrect email or password", withColor: .red)
                        self.textFieldsHoldAlert[1] = true
                    }
                }
            } else {
                passwordTextField.text = ""
                passwordTextField.changePlaceholderText(to: "Enter your password", withColor: .red)
                textFieldsHoldAlert[1] = true
            }
        } else {
            emailTextField.text = ""
            emailTextField.changePlaceholderText(to: "Enter your email", withColor: .red)
            textFieldsHoldAlert[0] = true
        }
    }
    
    
    @objc func showHidePassword(_ sender: UIButton) {
        if sender == passwordTextField.rightView {
            passwordTextField.togglePasswordVisibility()
        }
    }
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is RegisterNavController {
			let registerNavContoller = segue.destination as! RegisterNavController
			switch destination {
				case destinationContinueRegister:
					let confirmRegisterVC = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.confirmRegisterVC) as! ConfirmRegistrationViewController
					registerNavContoller.viewControllers = [confirmRegisterVC]
					let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: confirmRegisterVC, action: #selector(confirmRegisterVC.cancelButtonPressed))
					confirmRegisterVC.navigationItem.leftBarButtonItem = cancelButton
				default:
					break
			}
		}
	}
	
}



extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            textField.changePlaceholderText(to: "Email")
        } else if textField == passwordTextField {
            textField.changePlaceholderText(to: "Password")
        }
        
    }
}
