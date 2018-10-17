//
//  KeyboardViewController.swift
//  PostLaMode
//
//  Created by Ryan Bigger on 5/24/17.
//  Copyright © 2017 Evus Technologies. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    deinit {
        removeKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Keyboard
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let size = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        let curve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        
        keyboardWillShow(size: size!, duration: duration!, curve: curve!)
    }
    
    func keyboardWillShow(size: CGSize, duration: Double, curve: UInt) {
        // override in view controller
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let size = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        let curve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        keyboardWillHide(size: size!, duration: duration!, curve: curve!)
    }
    
    func keyboardWillHide(size: CGSize, duration: Double, curve: UInt) {
        // override in view controller
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

    
