//
//  RegisterViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    var textFields: [UITextField] = []
    var textFieldsHoldAlert = [false, false, false, false]
    
    var spinnerView = LoadingView()
    
    var willContinueRegistration = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
                
        textFields = [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField]
        for textField in textFields {
            textField.delegate = self
        }
        UITextField.format(textFields: textFields, height: 40, padding: 10)

        hideKeyboardWhenTappedAround()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.makeTransparent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.makeTransparent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !willContinueRegistration {
            Helpers.removeUserFromDefaults()
        }
        navigationController?.returnToOriginalState()
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
    
    

    @IBAction func continuePressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: K.Segues.registerToConfirm, sender: self)
//        return
        
        var isValid = true
        
        if firstNameTextField.text?.isEmptyOrWhitespace() ?? true {
            firstNameTextField.changePlaceholderText(to: "You must provide a first name", withColor: .red)
            isValid = false
            textFieldsHoldAlert[0] = true
        }
        if lastNameTextField.text?.isEmptyOrWhitespace() ?? true {
            lastNameTextField.changePlaceholderText(to: "You must provide a last name", withColor: .red)
            isValid = false
            textFieldsHoldAlert[1] = true
        }
        if let email = emailTextField.text, email != "" {
            if !email.isValidEmail() {
                emailTextField.text = ""
                emailTextField.changePlaceholderText(to: "Invalid email adress", withColor: .red)
                isValid = false
                textFieldsHoldAlert[2] = true
            }
        } else {
            emailTextField.changePlaceholderText(to: "You must provide an email adress", withColor: .red)
            isValid = false
            textFieldsHoldAlert[2] = true
        }
        if let phoneNumber = phoneNumberTextField.text, phoneNumber != "" {
            if !phoneNumber.isValidPhoneNumber(isFormatted: true) {
                phoneNumberTextField.text = ""
                phoneNumberTextField.changePlaceholderText(to: "Invalid phone number", withColor: .red)
                isValid = false
                textFieldsHoldAlert[3] = true
            }
        } else {
            phoneNumberTextField.changePlaceholderText(to: "You must provide a phone number", withColor: .red)
            isValid = false
            textFieldsHoldAlert[3] = true
        }
        
        if isValid {
            guard let phoneNumber = phoneNumberTextField.text?.getRawPhoneNumber() else { return }
            guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            
            continueButton.isUserInteractionEnabled = false
            hideKeyboard()
            spinnerView.create(parentVC: self)
            
            let db = Firestore.firestore()
            db.collection(K.Firebase.CollectionNames.users).whereField(K.Firebase.UserFieldNames.phoneNumber, isEqualTo: phoneNumber).getDocuments() { (querySnapshot, error) in
                    
                    if querySnapshot == nil || querySnapshot!.isEmpty {
                        
                        db.collection(K.Firebase.CollectionNames.users).whereField(K.Firebase.UserFieldNames.email, isEqualTo: email).getDocuments { (querySnapshot2, error2) in
                            
                            if querySnapshot2 == nil || querySnapshot2!.isEmpty {
                                
                                self.continueButton.isUserInteractionEnabled = false
                                self.willContinueRegistration = true
                                PhoneAuthProvider.provider().verifyPhoneNumber("+1\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))", uiDelegate: nil) { (verificationID, error) in
                                    self.spinnerView.remove()
                                    self.continueButton.isUserInteractionEnabled = true
                                    if error == nil {
                                        guard let verificationID = verificationID else {
                                            Alerts.showNoOptionAlert(title: "Error verifying phone number", message: "An error has occurred while retrieving verification code", sender: self)
                                            return
                                        }
                                        
                                        UserDefaults.standard.set(verificationID, forKey: K.UserDefaultKeys.verificationID)
                                        UserDefaults.standard.set(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.phoneNumber)
                                        UserDefaults.standard.set(self.phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.phoneNumberFormatted)
                                        UserDefaults.standard.set(self.firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.firstName)
                                        UserDefaults.standard.set(self.lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.lastName)
                                        UserDefaults.standard.set(self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.email)
                                        UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.sentVerificationCode)
                                        
                                        self.continueButton.isUserInteractionEnabled = true
                                        self.performSegue(withIdentifier: K.Segues.registerToConfirm, sender: self)
                                    } else {
                                        
                                        Alerts.showNoOptionAlert(title: "Error sending verification code", message: "Error description: \(error!.localizedDescription)", sender: self)
                                        self.continueButton.isUserInteractionEnabled = true
                                    }
                                }
                            } else if !querySnapshot2!.isEmpty {
                                self.continueButton.isUserInteractionEnabled = true
                                self.spinnerView.remove()
                                self.emailTextField.text = ""
                                self.emailTextField.changePlaceholderText(to: "Email taken", withColor: .red)
                            } else if error2 != nil {
                                self.spinnerView.remove()
                                Alerts.showNoOptionAlert(title: "Error Sending verification code", message: "Please check your internet connection, restart the app, and try again. Error description: \(error!.localizedDescription)", sender: self)
                            }
                        }
                    } else if !querySnapshot!.isEmpty {
                        self.continueButton.isUserInteractionEnabled = true
                        self.spinnerView.remove()
                        self.phoneNumberTextField.text = ""
                        self.phoneNumberTextField.changePlaceholderText(to: "Phone number taken", withColor: .red)
                    } else if error != nil {
                        self.continueButton.isUserInteractionEnabled = true
                        self.spinnerView.remove()
                        Alerts.showNoOptionAlert(title: "Error Sending verification code", message: "Please check your internet connection, restart the app, and try again. Error description: \(error!.localizedDescription)", sender: self)
                    }
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConfirmRegistrationViewController {
            (segue.destination as! ConfirmRegistrationViewController).firstName = firstNameTextField.text
            (segue.destination as! ConfirmRegistrationViewController).lastName = lastNameTextField.text
            (segue.destination as! ConfirmRegistrationViewController).email = emailTextField.text
            (segue.destination as! ConfirmRegistrationViewController).phoneNumber = phoneNumberTextField.text?.getRawPhoneNumber()
        }
    }
    
}





extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == firstNameTextField {
            textField.changePlaceholderText(to: "First Name")
        } else if textField == lastNameTextField {
            textField.changePlaceholderText(to: "Last Name")
        } else if textField == emailTextField {
            textField.changePlaceholderText(to: "Email")
        } else if textField == phoneNumberTextField {
            textField.changePlaceholderText(to: "Phone Number")
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            var fullString = textField.text ?? ""
            fullString.append(string)
            if range.length == 1 {
                textField.text = Helpers.format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            } else {
                textField.text = Helpers.format(phoneNumber: fullString)
            }
            return false
        }
        return true
    }
}
