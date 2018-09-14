//
//  FormSection.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/17/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import Foundation

@objcMembers public class FormSection: NSObject, NSCoding {

    var footerHeight: Float?
    var footerTitle: String?
    var headerHeight: Float?
    var headerTitle: String?
    var hidden: Bool = false
    public var rows = [FormRow]()
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(footerHeight, forKey: "footerHeight")
        aCoder.encode(footerTitle, forKey: "footerTitle")
        aCoder.encode(headerHeight, forKey: "headerHeight")
        aCoder.encode(headerTitle, forKey: "headerTitle")
        aCoder.encode(hidden, forKey: "hidden")
        aCoder.encode(rows, forKey: "rows")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        footerHeight = aDecoder.decodeObject(forKey: "footerHeight") as? Float
        footerTitle = aDecoder.decodeObject(forKey: "footerTitle") as? String
        headerHeight = aDecoder.decodeObject(forKey: "headerHeight") as? Float
        headerTitle = aDecoder.decodeObject(forKey: "headerTitle") as? String
        hidden = aDecoder.decodeBool(forKey: "hidden")
        rows = aDecoder.decodeObject(forKey: "rows") as! [FormRow]
    }
}
