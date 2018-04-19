//
//  SLActionSheet.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

public class SLActionSheet: UIActionSheet, UIActionSheetDelegate {

    private lazy var actionDict: [Int: SLEmptyClosure] = { return [:] }()
    
    public init(title aTitle: String?) {
        super.init(frame: CGRect.zero)
        
        if let atitle = aTitle {
            title = atitle
        }
        delegate = self
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension SLActionSheet {
    
    public func addAction(_ title:String?, _ style: UIAlertActionStyle, _ action: SLEmptyClosure? = nil) {
        let index = addButton(title, action)
        
        switch style {
        case .cancel:
            cancelButtonIndex = index
        
        case .destructive:
            destructiveButtonIndex = index
            
        case .default: break
        
        }
        
    }
    
    private func addButton(_ title: String?, _ action: SLEmptyClosure? = nil) -> Int {
        let index = addButton(withTitle: title)
        if let action = action {
            actionDict[index] = action
        }
        return index
    }
    
}

extension SLActionSheet {
    
    public func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if let action = actionDict[buttonIndex] {
            action()
            actionDict.removeAll()
        }
    }
    
}
