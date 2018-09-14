//
//  FormUtilities.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/25/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import Foundation

@objcMembers public class FormUtilities: NSObject {

    public class func simpleNumber(_ number: String) -> String {
        let regex = "[\\s-\\(\\)]"
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let results = regex.stringByReplacingMatches(in: number, options: [], range: NSMakeRange(0, number.count) , withTemplate: "")
            return results
        } catch {
            return ""
        }
    }
    
    public class func formatPhoneNumber(_ phone: String, deleteLastChar: Bool) -> String {
        if phone.isEmpty {
            return ""
        }
        var phoneNumber = simpleNumber(phone)
        let phoneNumberCount = phoneNumber.count
        
        // check if the number is to long
        if phoneNumber.count > 10 {
            let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: 9)
            phoneNumber = String(phoneNumber[...index])
        }
        
        if deleteLastChar == true {
            if phoneNumberCount == 1 {
                return ""
            }
            let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumberCount - 2)
            phoneNumber = String(phoneNumber[...index])
        }
        
        // (000) 000-0000
        if phoneNumberCount < 7 {
            phoneNumber = phoneNumber.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: nil)
        } else {
            phoneNumber = phoneNumber.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
        }
        return phoneNumber
    }
    
    public class func formatSSNumber(_ ssn: String, deleteLastChar: Bool) -> String {
        if ssn.isEmpty {
            return ""
        }
        var ssNumber = simpleNumber(ssn)
        let ssNumberCount = ssNumber.count
        
        // check if the number is to long
        if ssNumberCount > 9 {
            let index = ssNumber.index(ssNumber.startIndex, offsetBy: 8)
            ssNumber = String(ssNumber[...index])
        }
        
        if deleteLastChar == true {
            if ssNumberCount == 1 {
                return ""
            }
            let index = ssNumber.index(ssNumber.startIndex, offsetBy: ssNumberCount - 2)
            ssNumber = String(ssNumber[...index])
        }
        
        // 000-00-0000
        if (ssNumberCount < 6) {
            ssNumber = ssNumber.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "$1-$2", options: .regularExpression, range: nil)
        } else {
            ssNumber = ssNumber.replacingOccurrences(of: "(\\d{3})(\\d{2})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
        }
        return ssNumber
    }
    
    /* Example
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 123 {
            let fullString = "\(textField.text!)\(string)"
            textField.text = formatPhoneNumber(phone: fullString, deleteLastChar: (range.length == 1))
            return false
        }
        return true
    }
     */
}
