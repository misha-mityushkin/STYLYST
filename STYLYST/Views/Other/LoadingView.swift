//
//  LoadingView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-11.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class LoadingView: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
	
	@IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func create(parentVC: UIViewController) {
        // add the spinner view controller
        parentVC.addChild(self)
		print("parentVC.view w: \(parentVC.view.frame.width), h: \(parentVC.view.frame.height)")
        self.view.frame = parentVC.view.frame
        parentVC.view.addSubview(self.view)
        self.didMove(toParent: parentVC)
        self.spinner.startAnimating()
    }
    
    func remove() {
        self.spinner.stopAnimating()
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
