
//
//  SLInfoPlist.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/18.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import Foundation

public class SLInfoPlist: NSObject {
    
    
    
    public class var bundleID: String {
        if let bundleID = infoPlist["CFBundleIdentifier"] as? String {
            return bundleID
        }
        return ""
    }
    
    public class var infoPlist: [String: Any] {
        return Bundle.main.infoDictionary ?? [:]
    }
    
}


