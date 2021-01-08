//
//  DateExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2021-01-02.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import Foundation

extension Date {
	
	var monthString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter.string(from: self)
	}
	
	func dateStringWith(strFormat: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = Calendar.current.timeZone
		dateFormatter.locale = Calendar.current.locale
		dateFormatter.dateFormat = strFormat
		return dateFormatter.string(from: self)
	}
	
	func dayOfWeekCapitalized() -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.string(from: self).capitalized
		// or use capitalized(with: locale) if you want
	}
	
	func dayOfWeek() -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.string(from: self).lowercased()
		// or use capitalized(with: locale) if you want
	}
	
	func dayNumberOfWeek() -> Int? {
		return Calendar.current.dateComponents([.weekday], from: self).weekday
	}
	
}
