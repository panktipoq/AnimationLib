//
//  BasePListHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/22/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation


open class BasePListHelper{
    open lazy var plistDictionary:Dictionary<String, AnyObject> = {
        [unowned self] in
        return self.read()
    }()
    
    open func read() -> Dictionary<String, AnyObject> {
        return Dictionary<String, AnyObject>()
    }
    
    open func getValue(_ key:String)->String {
        if key.isEmpty {
            return ""
        }
        if let plistValue: AnyObject = plistDictionary[key] {
            return plistValue as! String
        }
        else {
            return ""
        }
    }
    
    open func getArrayValue(_ key: String) -> NSArray {
        if key.isEmpty{
            return []
        }
        if let plistValue: AnyObject = plistDictionary[key]{
            return plistValue as! NSArray
        }
        else
        {return []}
    }
}
