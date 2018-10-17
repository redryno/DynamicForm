//
//  FormRow.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/15/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit

@objcMembers public class FormRow: NSObject, NSCopying, NSCoding {
    
    public var accessoryType: UITableViewCell.AccessoryType = .none
    var cellIdentifier: String = "Cell"
    var hidden: Bool = false
    public var height: CGFloat = 44.0
    public var items = [FormItem]()
    public var name: String = "form_row_name"
    public var segue: String?
    public var selectionStyle: UITableViewCell.SelectionStyle = .default
    
    override public var description: String {
        get {
            var lines = [String]()
            lines.append("")
            lines.append("  accessoryType: `\(accessoryType)")
            lines.append("  cellIdentifier: `\(cellIdentifier)`")
            lines.append("  hidden: `\(hidden)`")
            lines.append("  height: `\(height)`")
            lines.append("  items: `\(items)`")
            lines.append("  name: `\(name)`")
            lines.append("  segue: `\(segue ?? "null")`")
            lines.append("  selectionStyle: `\(selectionStyle)`")
            return lines.joined(separator: "\n")
        }
    }
    
    public init(cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(accessoryType.rawValue, forKey: "accessoryType")
        aCoder.encode(cellIdentifier, forKey: "cellIdentifier")
        aCoder.encode(height, forKey: "height")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(hidden, forKey: "hidden")
        aCoder.encode(items, forKey: "items")
        aCoder.encode(segue, forKey: "segue")
        aCoder.encode(selectionStyle.rawValue, forKey: "selectionStyle")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let accessoryTypeRawValue = aDecoder.decodeInteger(forKey: "accessoryType")
        accessoryType = UITableViewCell.AccessoryType(rawValue: accessoryTypeRawValue)!
        cellIdentifier = aDecoder.decodeObject(forKey: "cellIdentifier") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        hidden = aDecoder.decodeBool(forKey: "hidden")
        items = aDecoder.decodeObject(forKey: "items") as! [FormItem]
        segue = aDecoder.decodeObject(forKey: "segue") as? String
        let selectionStyleRawValue = aDecoder.decodeInteger(forKey: "selectionStyle")
        selectionStyle = UITableViewCell.SelectionStyle(rawValue: selectionStyleRawValue)!
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = FormRow(cellIdentifier: cellIdentifier)
        copy.accessoryType = accessoryType
        copy.hidden = hidden
        copy.height = height
        copy.name = name
        copy.segue = segue
        copy.selectionStyle = selectionStyle
        for item in items {
            if let itemCopy = item.copy() as? FormItem {
                copy.items.append(itemCopy)
            }
        }
        return copy
    }
    
    public func contains(type: FormItemType) -> Bool {
        for item in items {
            if item.type == type {
                return true
            }
        }
        return false
    }
    
    public func keyItem() -> FormItem? {
        for item in items {
            if item.key != nil {
                return item
            }
        }
        return nil
    }
    
    public func items(withType type: FormItemType) -> [FormItem]? {
        var results = [FormItem]()
        for item in items {
            if item.type == type {
                results.append(item)
            }
        }
        if results.isEmpty {
            return nil
        }
        return results
    }
    
}
