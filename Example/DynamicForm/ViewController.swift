//
//  ViewController.swift
//  DynamicForm
//
//  Created by redryno on 07/06/2018.
//  Copyright (c) 2018 redryno. All rights reserved.
//

import UIKit
import DynamicForm

class ViewController: KeyboardViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource {
    
    var formInfo = FormInfo()
    var mediaInfo = [String]()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Intelligence Bulletin"
        
        formInfo.load(filename: "IntelligenceBulletin", for: tableView)
        
        formInfo.unarchiveSections();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    private func formatDateRows() {
        guard let dob = formInfo.item(forKey: "subjectDOB") else {
            return
        }
        dob.dateFormatter?.dateFormat = "MMM d, yyyy"
        formInfo.reloadRows(at: ["subjectDOB"], with: .none)
    }
    
    private func handleResponse(row: FormRow, display: String, value: String) {
        if let item = row.keyItem() {
            item.display = display
            item.rawValue = value
            formInfo.reloadRows(at: ["status", "vehicleRegistrationState"], with: .none)
        }
    }
    
    private func hidePicker() {
        if let rowIndexPath = formInfo.indexPath(with: "datePicker") {
            let dateIndexPath = IndexPath(row: rowIndexPath.row - 1, section: rowIndexPath.section)
            if let dateRow = formInfo.row(at: dateIndexPath) {
                // Set the label text color for the date and update the table view cell
                let keyItem = dateRow.keyItem()!
                keyItem.textColor = .black
                
                if let cell = tableView.cellForRow(at: dateIndexPath),
                    let label = cell.viewWithTag(101) as? UILabel {
                    label.textColor = .black
                }
                
                // Remove the date picker
                tableView.beginUpdates()
                formInfo.removeRow(name: "datePicker")
                tableView.endUpdates()
            }
        }
    }
    
    private func showPicker(name pickerName: String, for row: FormRow, at indexPath: IndexPath) {
        view.endEditing(true)
        
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let keyItem = row.keyItem()!
        let cell = tableView.cellForRow(at: indexPath)
        let label = cell?.viewWithTag(101)
        
        var sameCellTapped = false
        
        // If a picker is already visible in a form, remove it.
        if let rowIndexPath = formInfo.indexPath(with: pickerName) {
            
            // Check if this same input row has been selected
            let inputIndexPath = IndexPath(row: rowIndexPath.row - 1, section: rowIndexPath.section)
            sameCellTapped = (inputIndexPath == indexPath)
            
            // Reset the label text color and update the table view cell
            keyItem.textColor = .black
            if let label = label as? UILabel {
                label.textColor = .black
            }
            
            // Remove the picker
            formInfo.removeRow(name: pickerName)
        }
        
        // If the same input row was not selected, insert a picker
        if sameCellTapped == false {
            guard let pickerRow = formInfo.definedRow(with: pickerName) else {
                return
            }
            
            // Set the default value
            if (keyItem.rawValue == nil) {
                let date = Date().addingTimeInterval((60 * 60 * 24 * 365 * -18))
                keyItem.rawValue = date
                keyItem.display = date
            }
            
            // Insert the picker after the input cell
            let picker = pickerRow.items.first!
            picker.display = keyItem.rawValue
            formInfo.insert(row: pickerRow, after: row.name)
            
            // Set the label text color
            let color = UIColor(red: 0.0, green: 0.4784, blue: 1.0, alpha: 1.0)
            keyItem.textColor = color
            
            // Update the table view cell
            if let label = label as? UILabel {
                label.textColor = color
                if let value = keyItem.display as? Date, let dateFormatter = keyItem.dateFormatter {
                    label.text = dateFormatter.string(from: value)
                }
            }
        }
        tableView.endUpdates()
    }
    
    // MARK: - Keyboard Handling
    
    override func keyboardWillShow(size: CGSize, duration: Double, curve: UInt) {
        var insets = tableView.contentInset
        insets.bottom = size.height
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        self.hidePicker()
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        var insets = tableView.contentInset
        insets.bottom = 0
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    // MARK: - IBActions
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        formInfo.save(datePicker: sender)
        formatDateRows()
    }
    
    @IBAction func didTapDoneButton(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        let values = formInfo.values()
        print(values)
        
        formInfo.archiveSections()
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        formInfo.save(value: sender.isOn, forView: sender)
    }
    
    @IBAction func didTapPhotoVideoButton(_ sender: UIButton) {
        view.endEditing(true)
        if let row = formInfo.row(with: "media") {
            mediaInfo.append("new")
            row.height = 137
            
            guard let cell = sender.superview?.superview as? UITableViewCell else {
                return
            }
            
            if let collectionView = cell.contentView.viewWithTag(101) as? UICollectionView {
                collectionView.reloadData()
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    @IBAction func didTapRemoveImageButton(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UICollectionViewCell else {
            return
        }
        
        if let collectionView = cell.superview as? UICollectionView,
            let indexPath = collectionView.indexPath(for: cell) {
            mediaInfo.remove(at: indexPath.item)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: { (finished: Bool) in
                if self.mediaInfo.count == 0 {
                    if let row = self.formInfo.row(with: "media") {
                        row.height = 44
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
            })
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let row = formInfo.row(with: "media") {
            row.height = 137
            tableView.reloadData()
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = formInfo.tableViewCell(in: tableView, at: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return formInfo.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formInfo.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formInfo.headerTitle(for: section)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height = formInfo.heightForFooter(at: section)
        return (height != 0) ? height : tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = formInfo.heightForHeader(at: section)
        return (height != 0) ? height : tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = formInfo.heightForRow(at: indexPath)
        return (height != 0) ? height : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = formInfo.row(at: indexPath) {
            DispatchQueue.main.async {
                if row.contains(type: .UITextField) || row.contains(type: .UITextView) {
                    let cell = tableView.cellForRow(at: indexPath)
                    for view in (cell?.contentView.subviews)! {
                        if view is UITextField || view is UITextView {
                            view.becomeFirstResponder()
                        }
                    }
                    tableView.deselectRow(at: indexPath, animated: false);
                } else if row.name == "subjectDOB" {
                    self.showPicker(name: "datePicker", for: row, at: indexPath)
                } else if let segue = row.segue {
                    self.performSegue(withIdentifier: segue, sender: row)
                } else {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
        }
    }
    
    // MARK: - UITextField
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        formInfo.save(value: textField.text, forView: textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let point = textField.superview?.convert(textField.center, to: tableView),
            let indexPath = tableView.indexPathForRow(at: point) {
            
            let fullString = "\(textField.text!)\(string)"
            if let row = formInfo.row(at: indexPath) {
                if row.name == "subjectPhone" {
                    textField.text = FormUtilities.formatPhoneNumber(fullString, deleteLastChar: (range.length == 1))
                    return false
                } else if row.name == "subjectSSN" {
                    textField.text = FormUtilities.formatSSNumber(fullString, deleteLastChar: (range.length == 1))
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - UITextView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // Scroll the view to make the text view visible
        if let point = textView.superview?.convert(textView.center, to: tableView),
            let indexPath = tableView.indexPathForRow(at: point) {
            let cellFrame = tableView.rectForRow(at: indexPath)
            let converted = self.view.convert(cellFrame, from: tableView)
            if (converted.maxY > tableView.frame.height - tableView.contentInset.bottom) {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        formInfo.save(value: textView.text, forView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // Adjust the size of the table view cell
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let height = size.height + 42;
        if let point = textView.superview?.convert(textView.center, to: tableView),
            let indexPath = tableView.indexPathForRow(at: point) {
            if let row = formInfo.row(at: indexPath) {
                if row.height != height {
                    row.height = height
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let viewController = segue.destination as! OptionsViewController
            if let row = sender as? FormRow {
                viewController.selected = row.keyItem()!.rawValue as? String
                if row.name == "status" {
                    viewController.title = "Status"
                    viewController.formInfoFile = "IntelligenceBulletinStatus"
                } else if row.name == "vehicleRegistrationState" {
                    viewController.title = "Registration State"
                    viewController.formInfoFile = "IntelligenceBulletinStates"
                }
                viewController.callBack = { (display, value) -> Void in
                    self.handleResponse(row: row, display: display, value: value)
                }
            }
        }
    }
}

