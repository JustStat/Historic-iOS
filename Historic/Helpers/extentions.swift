//
//  extentions.swift
//  Historic
//
//  Created by Kirill Varlamov on 03.05.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import Foundation

extension UIViewController: UITextFieldDelegate {
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
//        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func donePressed() {
        
    }
    
    func cancelPressed() {
        view.endEditing(true) // or do something
    }
}
