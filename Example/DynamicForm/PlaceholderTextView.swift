//
//  PlaceholderTextView.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/19/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    @IBInspectable var removeInsets: Bool = false {
        didSet {
            if removeInsets {
                self.textContainer.lineFragmentPadding = 0
                self.textContainerInset = .zero
                
                if !marginConstants.isEmpty {
                    for (_, constraint) in marginConstants {
                        constraint.constant = 0
                    }
                }
            }
        }
    }
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.placeholderLabel.text = placeholder
        }
    }
    private var marginConstants = [String : NSLayoutConstraint]()
    private var placeholderLabel: UILabel = UILabel()
    private var placeholderIsSet = false
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UITextViewTextDidChange,
                                                  object: nil)
    }
    
    func setup() {
        if placeholderIsSet {
            return
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(notification:)),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: nil)
        
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.font = self.font
        placeholderLabel.isHidden = (self.text.isEmpty == false)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.804, alpha: 1.0)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        
        let left = self.textContainerInset.left + self.textContainer.lineFragmentPadding
        let leftConstraint = NSLayoutConstraint(item: placeholderLabel,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1,
                                                constant: left)
        addConstraint(leftConstraint)
        marginConstants["left"] = leftConstraint
        
        let right = self.textContainerInset.right + self.textContainer.lineFragmentPadding
        let rightConstraint = NSLayoutConstraint(item: placeholderLabel,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1,
                                                 constant: right)
        addConstraint(rightConstraint)
        marginConstants["right"] = rightConstraint
        
        let top = self.textContainerInset.top
        let topConstraint = NSLayoutConstraint(item: placeholderLabel,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .top,
                                               multiplier: 1,
                                               constant: top)
        addConstraint(topConstraint)
        marginConstants["top"] = topConstraint
        
        placeholderIsSet = true
    }
    
    // MARK: -
    
    @objc func textDidChange(notification: NSNotification) {
        placeholderLabel.isHidden = (self.text.isEmpty == false)
    }

}
