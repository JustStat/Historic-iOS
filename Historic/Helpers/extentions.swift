//
//  extentions.swift
//  Historic
//
//  Created by Kirill Varlamov on 03.05.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

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
        textField.inputAccessoryView = toolBar
    }
    
    func donePressed() {}
    func cancelPressed() {}
}

extension UIViewController: UISearchBarDelegate {
    func addSearchBar() -> UISearchBar {
        let navBarSize = self.navigationController?.navigationBar.frame.size
        let searchBar = UISearchBar(frame: CGRect(origin: .zero, size: CGSize(width: (navBarSize?.width)! - 100, height: (navBarSize?.height)! - 10)))
        let searchBarItem = UIBarButtonItem(customView: searchBar)
        searchBar.placeholder = "Поиск"
        searchBar.barTintColor = UIColor.appColor().withAlphaComponent(0.5)
        self.navigationItem.leftBarButtonItem = searchBarItem;
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.backgroundColor = UIColor.appColor().withAlphaComponent(0.5)
        textField?.textColor = .white
        self.addToolBar(textField: textField!)
        
        let attributeDict = [NSForegroundColorAttributeName: UIColor.white]
        textField!.attributedPlaceholder = NSAttributedString(string: "Поиск", attributes: attributeDict)
        searchBar.setImage(UIImage(named: "search-ico"), for: .search, state: .normal)
        searchBar.setImage(UIImage(named: "search-cancel"), for: .clear, state: .normal)
        searchBar.delegate = self
        return searchBar
    }
}
