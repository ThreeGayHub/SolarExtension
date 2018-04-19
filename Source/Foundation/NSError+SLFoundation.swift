//
//  NSError+SLFoundation.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/18.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

public extension NSError {
    
    public convenience init(code: Int, message: String = "") {
        self.init(domain: SLInfoPlist.bundleID, code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
}
