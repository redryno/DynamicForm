//
//  FormItem.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/15/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit

@objcMembers public class FormItem: NSObject, NSCopying, NSCoding {
    
    var type: FormItemType!
    var tag: Int = 0
    
    // MARK: - Settings
    
    var autocorrectionType: UITextAutocorrectionType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .sentences
    public var dateFormatter: DateFormatter?
    var isHidden: Bool = false
    var isSecureTextEntry: Bool = false
    var keyboardType: UIKeyboardType = .default
    var placeholder: String?
    var spellCheckingType: UITextSpellCheckingType = .default
    public var textColor: UIColor?
    
    // MARK: - DatePicker

    var maximumDate: Date?
    var minimumDate: Date?
    var minuteInterval: Int?
    var datePickerMode: UIDatePicker.Mode?
    
    // MARK - PickerView
    
    public var components: [String]?
    public var selectedRow: Int?
    
    // MARK: - Value
    
    var isOptional: Bool = false
    public var key: String?
    public var display: Any?
    public var rawValue: Any?
    
    // MARK: - Initializers
    
    public init(type: FormItemType) {
        self.type = type
    }
    
    init(formItem: FormItem?) {
        guard let defaults = formItem else {
            return
        }
        
        type = defaults.type
        tag = defaults.tag
        
        autocorrectionType = defaults.autocorrectionType
        autocapitalizationType = defaults.autocapitalizationType
        dateFormatter = defaults.dateFormatter
        isSecureTextEntry = defaults.isSecureTextEntry
        keyboardType = defaults.keyboardType
        placeholder = defaults.placeholder
        spellCheckingType = defaults.spellCheckingType
        textColor = defaults.textColor
        
        maximumDate = defaults.maximumDate
        minimumDate = defaults.minimumDate
        minuteInterval = defaults.minuteInterval
        datePickerMode = defaults.datePickerMode
        
        isOptional = defaults.isOptional
        key = defaults.key
        display = defaults.display
        rawValue = defaults.rawValue
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(tag, forKey: "tag")
        
        aCoder.encode(autocorrectionType.rawValue, forKey: "autocorrectionType")
        aCoder.encode(autocapitalizationType.rawValue, forKey: "autocapitalizationType")
        aCoder.encode(dateFormatter, forKey: "dateFormatter")
        aCoder.encode(isHidden, forKey: "isHidden")
        aCoder.encode(isSecureTextEntry, forKey: "isSecureTextEntry")
        aCoder.encode(keyboardType.rawValue, forKey: "keyboardType")
        aCoder.encode(placeholder, forKey: "placeholder")
        aCoder.encode(spellCheckingType.rawValue, forKey: "spellCheckingType")
        aCoder.encode(textColor, forKey: "textColor")
        
        aCoder.encode(maximumDate, forKey: "maximumDate")
        aCoder.encode(minimumDate, forKey: "minimumDate")
        
        aCoder.encode(isOptional, forKey: "isOptional")
        aCoder.encode(key, forKey: "key")
        aCoder.encode(display, forKey: "display")
        aCoder.encode(rawValue, forKey: "rawValue")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let typeRawValue = aDecoder.decodeInteger(forKey: "type")
        type = FormItemType(rawValue: typeRawValue)!
        
        let autocorrectionTypeRawValue = aDecoder.decodeInteger(forKey: "autocorrectionType")
        autocorrectionType = UITextAutocorrectionType(rawValue: autocorrectionTypeRawValue)!
        
        let autocapitalizationTypeRawValue = aDecoder.decodeInteger(forKey: "autocapitalizationType")
        autocapitalizationType = UITextAutocapitalizationType(rawValue: autocapitalizationTypeRawValue)!
        
        let keyboardTypeRawValue = aDecoder.decodeInteger(forKey: "keyboardType")
        keyboardType = UIKeyboardType(rawValue: keyboardTypeRawValue)!
        
        let spellCheckingTypeRawValue = aDecoder.decodeInteger(forKey: "spellCheckingType")
        spellCheckingType = UITextSpellCheckingType(rawValue: spellCheckingTypeRawValue)!
        
        tag = aDecoder.decodeInteger(forKey: "tag")
        dateFormatter = aDecoder.decodeObject(forKey: "dateFormatter") as? DateFormatter
        isHidden = aDecoder.decodeBool(forKey: "isHidden")
        isSecureTextEntry = aDecoder.decodeBool(forKey: "isSecureTextEntry")
        placeholder = aDecoder.decodeObject(forKey: "placeHolder") as? String
        textColor = aDecoder.decodeObject(forKey: "textColor") as? UIColor
        maximumDate = aDecoder.decodeObject(forKey: "maximumDate") as? Date
        minimumDate = aDecoder.decodeObject(forKey: "minimumDate") as? Date
        isOptional = aDecoder.decodeBool(forKey: "isOptional")
        key = aDecoder.decodeObject(forKey: "key") as? String
        display = aDecoder.decodeObject(forKey: "display")
        rawValue = aDecoder.decodeObject(forKey: "rawValue")
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = FormItem(type: type)
        copy.type = type
        copy.tag = tag
        
        copy.autocorrectionType = autocorrectionType
        copy.autocapitalizationType = autocapitalizationType
        copy.dateFormatter = dateFormatter
        copy.isSecureTextEntry = isSecureTextEntry
        copy.keyboardType = keyboardType
        copy.placeholder = placeholder
        copy.spellCheckingType = spellCheckingType
        copy.textColor = textColor
        
        copy.maximumDate = maximumDate
        copy.minimumDate = minimumDate
        copy.minuteInterval = minuteInterval
        copy.datePickerMode = datePickerMode
        
        copy.isOptional = isOptional
        copy.key = key
        copy.display = display
        copy.rawValue = rawValue
        return copy
    }
}
