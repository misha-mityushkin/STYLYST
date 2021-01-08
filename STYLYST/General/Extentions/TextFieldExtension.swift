//
//  TextFieldExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UITextField {
    
    func changeTextFieldColor(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(self.frame.size)
        color.setFill()
        UIBezierPath(rect: self.frame).fill()
        let bgImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.background = bgImage
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    
    static func format(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            if #available(iOS 13.0, *) {
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
            }
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    static func formatBackground(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    static func formatPlaceholder(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    
    
    func changePlaceholderText(to newText: String, withColor color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func changePlaceholderText(to newText: String) {
        attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
    }
    
    
    
//    func togglePasswordVisibility() {
//        isSecureTextEntry.toggle()
//
//        if let existingText = text, isSecureTextEntry {
//            /* When toggling to secure text, all text will be purged if the user
//             continues typing unless we intervene. This is prevented by first
//             deleting the existing text and then recovering the original text. */
//            deleteBackward()
//
//            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
//                replace(textRange, withText: existingText)
//            }
//        }
//
//        /* Reset the selected text range since the cursor can end up in the wrong
//         position after a toggle because the text might vary in width */
//        if let existingSelectedTextRange = selectedTextRange {
//            selectedTextRange = nil
//            selectedTextRange = existingSelectedTextRange
//        }
//    }
    
    
    func setRightViewButton(icon: UIImage, width: CGFloat, height: CGFloat, parentVC: UIViewController, action: Selector) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        btnView.setImage(icon, for: .normal)
        btnView.tintColor = UIColor(named: K.ColorNames.goldenThemeColorInverseMoreContrast)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        btnView.addTarget(parentVC, action: action, for: .touchUpInside)
        self.rightViewMode = .always
        self.rightView = btnView
    }
}
