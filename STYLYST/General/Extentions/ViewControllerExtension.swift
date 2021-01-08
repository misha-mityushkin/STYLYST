//
//  ViewControllerExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
		view.addGestureRecognizer(swipeGesture)
    }
    
    func hideKeyboardWhenTappedAround(for view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
		view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
	
	func setUpGradientNavBar(colors: [CGColor]) {
		if let navigationBar = self.navigationController?.navigationBar {
			let gradient = CAGradientLayer()
			var bounds = navigationBar.bounds
			bounds.size.height += UIApplication.shared.statusBarFrame.size.height
			gradient.frame = bounds
			gradient.colors = colors
			gradient.startPoint = CGPoint(x: 0, y: 0)
			gradient.endPoint = CGPoint(x: 0, y: 1)
			if let image = getImageFrom(gradientLayer: gradient) {
				navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
				navigationItem.title = nil
			}
			
		}
	}
	private func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
		var gradientImage:UIImage?
		UIGraphicsBeginImageContext(gradientLayer.frame.size)
		if let context = UIGraphicsGetCurrentContext() {
			gradientLayer.render(in: context)
			gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
		}
		UIGraphicsEndImageContext()
		return gradientImage
	}
	func removeGradientNavBar() {
		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
	}
}
