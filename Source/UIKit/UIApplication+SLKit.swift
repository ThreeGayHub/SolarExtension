//
//  UIApplication+SLKit.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/13.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    public class func call(phoneNumber: String) {
        if let url = URL(string: "tel:\(phoneNumber)") {
            UIApplication.shared.openURL(url)
        }
    }
    
}
