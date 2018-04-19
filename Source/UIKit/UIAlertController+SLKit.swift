//
//  UIAlertController+SLKit.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    public func addAction(_ title:String?, _ style: UIAlertActionStyle, _ handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)
    }
    
    public func showInVC(_ vc: UIViewController) {
        vc.present(self, animated: true, completion: nil)
    }
    
    public func textField(at textFieldIndex: Int) -> UITextField? {
        if let textFields = textFields {
            if textFields.count > textFieldIndex {
                return textFields[textFieldIndex]
            }
        }
        return nil
    }
    
}
