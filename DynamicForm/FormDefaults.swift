//
//  FormDefaults.swift
//  FormExample
//
//  Created by Ryan Bigger on 9/21/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit

class FormDefaults {
    
    var accessoryType: UITableViewCell.AccessoryType = .none
    var height: CGFloat = 44.0
    var items = [String : FormItem]()
    var selectionStyle: UITableViewCell.SelectionStyle = .default
    
    func tableViewCell(withIdentifier identifier: String, tableView: UITableView) -> Bool {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            return false
        }
        
        accessoryType = cell.accessoryType
        height = cell.frame.height
        selectionStyle = cell.selectionStyle
        
        for cellSubview in cell.contentView.subviews {
            let formItem = FormItem(type: .none)
            
            if cellSubview is UILabel {
                let label = cellSubview as! UILabel
                formItem.textColor = label.textColor
                formItem.display = label.text
                
            } else if cellSubview is UISwitch {
                let toggleSwitch = cellSubview as! UISwitch
                formItem.display = toggleSwitch.isOn
                
            } else if cellSubview is UITextField {
                let textField = cellSubview as! UITextField
                formItem.autocapitalizationType = textField.autocapitalizationType
                formItem.autocorrectionType = textField.autocorrectionType
                formItem.display = textField.text
                formItem.isSecureTextEntry = textField.isSecureTextEntry
                formItem.keyboardType = textField.keyboardType
                formItem.placeholder = textField.placeholder
                formItem.spellCheckingType = textField.spellCheckingType
                formItem.textColor = textField.textColor
                
            } else if cellSubview is UITextView {
                let textView = cellSubview as! UITextView
                formItem.autocapitalizationType = textView.autocapitalizationType
                formItem.autocorrectionType = textView.autocorrectionType
                formItem.display = textView.text
                formItem.isSecureTextEntry = textView.isSecureTextEntry
                formItem.keyboardType = textView.keyboardType
                formItem.spellCheckingType = textView.spellCheckingType
                formItem.textColor = textView.textColor
                
            } else if cellSubview is UIDatePicker {
                let datePicker = cellSubview as! UIDatePicker
                formItem.maximumDate = datePicker.maximumDate
                formItem.minimumDate = datePicker.minimumDate
                formItem.minuteInterval = datePicker.minuteInterval
                formItem.datePickerMode = datePicker.datePickerMode
                
            }
            
            if cellSubview.tag > 0 {
                items["\(cellSubview.tag)"] = formItem
            }
            if cellSubview == cell.detailTextLabel {
                items["detailTextLabel"] = formItem
            } else if cellSubview == cell.textLabel {
                items["textLabel"] = formItem
            } else if cellSubview == cell.imageView {
                items["imageView"] = formItem
            }
        }
        return true
    }
    
    func item(type: FormItemType, tag: Int) -> FormItem? {
        if tag > 0 {
            return items["\(tag)"]
        } else if type == .detailTextLabel {
            return items["detailTextLabel"]
        } else if type == .textLabel {
            return items["textLabel"]
        }
        return nil
    }
    
}
