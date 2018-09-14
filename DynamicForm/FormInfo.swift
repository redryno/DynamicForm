//
//  FormInfo.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/15/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit

@objc public enum FormItemType: Int {
    case invalid
    case none
    case date
    case detailTextLabel
    case textLabel
    case UIDatePicker
    case UIImageView
    case UILabel
    case UIPickerView
    case UISegmentedControl
    case UITextField
    case UITextView
    case UISwitch
}

@objcMembers public class FormInfo: NSObject {
    var cells = [String : FormDefaults]()
    var definedSections = [FormSection]()
    public var sections = [FormSection]()
    var tableView: UITableView!
    
    public override init() {
        super.init()
    }
    
    public func values() -> [String : Any] {
        var values = [String : Any]()
        for section in sections {
            for row in section.rows {
                for item in row.items {
                    if let key = item.key {
                        values[key] = item.rawValue
                    }
                }
            }
        }
        return values
    }
    
    // MARK: - JSON Conversion
    
    private func convertFormItemType(_ type: String) -> FormItemType {
        switch type {
        case "none": return .none
        case "date": return .date
        case "detailTextLabel": return .detailTextLabel
        case "textLabel": return .textLabel
        case "UIDatePicker": return .UIDatePicker
        case "UIImageView": return .UIImageView
        case "UILabel": return .UILabel
        case "UIPickerView": return .UIPickerView
        case "UISegmentedControl": return .UISegmentedControl
        case "UITextField": return .UITextField
        case "UITextView": return .UITextView
        case "UISwitch": return .UISwitch
        default: return .invalid
        }
    }
    
    // MARK: - Load
    
    private func cellDefaults(_ cellIdentifier: String) -> FormDefaults? {
        let savedDefaults = cells[cellIdentifier]
        if savedDefaults != nil {
            return savedDefaults
        }
        
        let defaults = FormDefaults()
        if defaults.tableViewCell(withIdentifier: cellIdentifier, tableView: tableView) {
            cells[cellIdentifier] = defaults
            return defaults
        }
        
        return nil
    }
    
    public func load(data: Data, for tableView: UITableView) {
        self.tableView = tableView
        loadSections(data: data as Data)
    }
    
    public func load(filename: String, for tableView: UITableView) {
        self.tableView = tableView
        
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("• File Error: Unable to build path to JSON file (\(filename).json)")
            return
        }
        
        do {
            let fileContents = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
            loadSections(data: fileContents as Data)
        } catch let error {
            print("• Data Error: \(error.localizedDescription)")
        }
    }
    
    private func loadItems(section: Int, row: Int, jsonRow: [String : Any], cellDefaults: FormDefaults) -> [FormItem] {
        var items = [FormItem]()
        
        guard let jsonItems = jsonRow["items"] as? [[String : Any]] else {
            print("• Parse Error: No items at section [\(section)] row [\(row)]")
            return items
        }
        
        for (itemIndex, jsonItem) in jsonItems.enumerated() {
            guard let itemType = jsonItem["type"] as? String else {
                print("• Parse Error: Missing type at section [\(section)] row [\(row)] item [\(itemIndex)]")
                continue
            }
            let type = convertFormItemType(itemType)
            if (type == .invalid) {
                print("• Parse Error: Invalid type at section [\(section)] row [\(row)] item [\(itemIndex)]")
                continue
            }
            
            let tag = jsonItem["tag"] as? Int ?? 0
            let defaults = cellDefaults.item(type: type, tag: tag);
            
            let formItem = FormItem(formItem: defaults)
            formItem.tag = tag
            formItem.type = type
            formItem.rawValue = jsonItem["value"]
            
            if let display = jsonItem["display"] {
                formItem.display = display
            }
            
            if let isHidden = jsonItem["hidden"] as? Bool {
                formItem.isHidden = isHidden
            }
            
            if let autocorrection = jsonItem["autocorrectionType"] as? Int,
                let autocorrectionType = UITextAutocorrectionType(rawValue: autocorrection) {
                formItem.autocorrectionType = autocorrectionType
            }
            
            if let autocapitalization = jsonItem["autocapitalizationType"] as? Int,
                let autocapitalizationType = UITextAutocapitalizationType(rawValue: autocapitalization) {
                formItem.autocapitalizationType = autocapitalizationType
            }
            
            if let isSecureTextEntry = jsonItem["isSecureTextEntry"] as? Bool {
                formItem.isSecureTextEntry = isSecureTextEntry
            }
            
            if let key = jsonItem["key"] as? String {
                formItem.key = key
            }
            
            if let keyboard = jsonItem["keyboardType"] as? Int,
                let keyboardType = UIKeyboardType(rawValue: keyboard) {
                formItem.keyboardType = keyboardType
            }
            
            if let placeholder = jsonItem["placeholder"] as? String {
                formItem.placeholder = placeholder
            }
            
            if let spellChecking = jsonItem["spellCheckingType"] as? Int,
                let spellCheckingType = UITextSpellCheckingType(rawValue: spellChecking) {
                formItem.spellCheckingType = spellCheckingType
            }
            
            if let textColor = jsonItem["rgbTextColor"] as? [CGFloat] {
                formItem.textColor = UIColor(red: textColor[0], green: textColor[1], blue: textColor[2], alpha: textColor[3])
            }
            
            if type == .date {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone.current
                
                if let dateFormat = jsonItem["dateFormat"] as? String {
                    dateFormatter.dateFormat = dateFormat
                }
                
                if let dateStyle = jsonItem["dateStyle"] as? UInt,
                    let dateFormaterStyle = DateFormatter.Style(rawValue: dateStyle) {
                    dateFormatter.dateStyle = dateFormaterStyle
                }
                
                if let timeStyle = jsonItem["timeStyle"] as? UInt,
                    let dateFormaterStyle = DateFormatter.Style(rawValue: timeStyle) {
                    dateFormatter.timeStyle = dateFormaterStyle
                }
                
                if let date = jsonItem["date"] as? String {
                    if date == "Now" {
                        let value = Date()
                        formItem.display = value
                        formItem.rawValue = value
                    } else {
                        let value = dateFormatter.date(from: date)
                        formItem.display = value
                        formItem.rawValue = value
                    }
                }
                
                formItem.dateFormatter = dateFormatter
            }
            
            if type == .UIDatePicker {
                if let minuteInterval = jsonItem["minuteInterval"] as? Int {
                    formItem.minuteInterval = minuteInterval
                }
                if let dateMode = jsonItem["datePickerMode"] as? Int,
                    let datePickerMode = UIDatePickerMode.init(rawValue: dateMode) {
                    formItem.datePickerMode = datePickerMode
                }
            }
            
            if type == .UIPickerView {
                if let components = jsonItem["components"] as? [String] {
                    formItem.components = components
                }
                if let selectedRow = jsonItem["selected"] as? Int {
                    formItem.selectedRow = selectedRow
                }
            }
            
            items.append(formItem)
        }
        return items
    }
    
    private func loadRows(section: Int, jsonSection: [String: Any]) -> [FormRow] {
        var rows = [FormRow]()
        
        guard let jsonRows = jsonSection["rows"] as? [[String : Any]] else {
            print("• Parse Error: No rows at section [\(section)]")
            return rows
        }
        
        for (rowIndex, jsonRow) in jsonRows.enumerated() {
            guard let identifier = jsonRow["cellIdentifier"] as? String else {
                print("• Parse Error: No cell identifier at section [\(section)] row [\(rowIndex)]")
                continue
            }
            
            guard let defaults = cellDefaults(identifier) else {
                print("• Parse Error: Unable to dequeue a cell with identifier \(identifier)")
                continue
            }
            
            let formRow = FormRow(cellIdentifier: identifier)
            formRow.accessoryType = defaults.accessoryType
            formRow.height = defaults.height
            formRow.selectionStyle = defaults.selectionStyle
            
            if let name = jsonRow["name"] as? String {
                formRow.name = name
            }
            
            if let height = jsonRow["height"] as? CGFloat {
                formRow.height = height
            }
            
            if let hidden = jsonRow["hidden"] as? Bool {
                formRow.hidden = hidden
            }
            
            if let segue = jsonRow["segue"] as? String {
                formRow.segue = segue
            }
            
            if let accessoryType = jsonRow["accessoryType"] as? String {
                switch accessoryType {
                case "disclosureIndicator":
                    formRow.accessoryType = .disclosureIndicator
                    break
                case "detailDisclosureButton":
                    formRow.accessoryType = .detailDisclosureButton
                    break
                case "checkmark":
                    formRow.accessoryType = .checkmark
                    break
                case "detailButton":
                    formRow.accessoryType = .detailButton
                    break
                default:
                    formRow.accessoryType = defaults.accessoryType
                    break
                }
            }
            
            if let selectionStyle = jsonRow["selectionStyle"] as? String {
                switch selectionStyle {
                case "blue":
                    formRow.selectionStyle = .blue
                    break
                case "gray":
                    formRow.selectionStyle = .gray
                    break
                case "none":
                    formRow.selectionStyle = .none
                    break
                default:
                    formRow.selectionStyle = .default
                    break
                }
            }
            
            formRow.items = loadItems(section: section, row: rowIndex, jsonRow: jsonRow, cellDefaults: defaults)
            rows.append(formRow)
        }
        return rows
    }
    
    private func loadSections(data: Data) {
        do {
            let jsonSections = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [[String : Any]]
            for (sectionIndex, jsonSection) in jsonSections.enumerated() {
                let formSection = FormSection()
                formSection.footerHeight = jsonSection["footerHeight"] as? Float
                formSection.footerTitle = jsonSection["footerTitle"] as? String
                formSection.headerHeight = jsonSection["headerHeight"] as? Float
                formSection.headerTitle = jsonSection["headerTitle"] as? String
                if let hidden = jsonSection["hidden"] as? Bool {
                    formSection.hidden = hidden
                }
                
                formSection.rows = loadRows(section: sectionIndex, jsonSection: jsonSection)
                definedSections.append(formSection)
                
                if formSection.hidden == false {
                    let filteredSection = FormSection()
                    filteredSection.footerHeight = formSection.footerHeight
                    filteredSection.footerTitle = formSection.footerTitle
                    filteredSection.headerHeight = formSection.headerHeight
                    filteredSection.headerTitle = formSection.headerTitle
                    filteredSection.rows = formSection.rows.filter({ $0.hidden == false })
                    self.sections.append(filteredSection)
                }
            }
        } catch let error {
            print("• JSON Error: \(error.localizedDescription)")
        }
    }
    
    public func map(_ run: (FormSection, FormRow, FormItem)->()) {
        for section in sections {
            for row in section.rows {
                for item in row.items {
                    run(section, row, item)
                }
            }
        }
    }
    
    // MARK: -
    
    public func reloadRows(at rows: [String], with animation: UITableViewRowAnimation) {
        var indexPaths = [IndexPath]()
        for (i, section) in sections.enumerated() {
            for (j, row) in section.rows.enumerated() {
                if rows.contains(row.name) {
                    let indexPath = IndexPath(row: j, section: i)
                    indexPaths.append(indexPath)
                }
            }
        }
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    // MARK: - Insert/Remove
    
    public func append(row: FormRow, atSection sectionIndex: Int) {
        let rowInfo = self.row(with: row.name)
        if rowInfo != nil {
            return
        }
        let section = sections[sectionIndex]
        let rowIndex = section.rows.count
        section.rows.append(row)
        
        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    public func appendRow(name: String, atSection sectionIndex: Int) {
        if let row = definedRow(with: name) {
            self.append(row: row, atSection: sectionIndex)
        }
    }
    
    public func insert(row: FormRow, after: String) {
        let rowInfo = self.row(with: row.name)
        if rowInfo != nil {
            return
        }
        if let rowIndexPath = self.indexPath(with: after) {
            let indexPath = IndexPath(row: rowIndexPath.row + 1, section: rowIndexPath.section)
            let section = sections[indexPath.section]
            section.rows.insert(row, at: indexPath.row)
            tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    public func insertRow(name: String, after: String) {
        if let row = definedRow(with: name) {
            self.insert(row: row, after: after)
        }
    }
    
    public func insert(row: FormRow, before: String) {
        let rowInfo = self.row(with: row.name)
        if rowInfo != nil {
            return
        }
        if let indexPath = self.indexPath(with: before) {
            let section = sections[indexPath.section]
            section.rows.insert(row, at: indexPath.row)
            tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    public func removeRow(name: String) {
        if let indexPath = self.indexPath(with: name) {
            let section = sections[indexPath.section]
            section.rows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    public func removeAt(indexPath: IndexPath) {
        let section = sections[indexPath.section]
        section.rows.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Get
    
    public func definedRow(with name: String) -> FormRow? {
        for section in definedSections {
            for row in section.rows {
                if row.name == name {
                    return row
                }
            }
        }
        return nil
    }
    
    public func indexPath(forView view: UIView) -> IndexPath? {
        if let point = view.superview?.convert(view.center, to: tableView),
            let indexPath = tableView.indexPathForRow(at: point) {
            return indexPath
        }
        return nil
    }
    
    public func indexPath(with name: String) -> IndexPath? {
        for (i, section) in sections.enumerated() {
            for (j, row) in section.rows.enumerated() {
                if row.name == name {
                    let indexPath = IndexPath(row: j, section: i)
                    return (indexPath)
                }
            }
        }
        return nil
    }
    
    public func item(forKey key: String) -> FormItem? {
        for section in sections {
            for row in section.rows {
                for item in row.items {
                    if item.key == key {
                        return item
                    }
                }
            }
        }
        return nil
    }
    
    public func row(with name: String) -> (FormRow)? {
        for section in sections {
            for row in section.rows {
                if row.name == name {
                    return (row)
                }
            }
        }
        return nil
    }
    
    public func row(at indexPath: IndexPath) -> FormRow? {
        if (indexPath.section < 0 || indexPath.row < 0) {
            return nil
        }
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        return row
    }
    
    // MARK: - TableView Data
    
    public func heightForFooter(at section: Int) -> CGFloat {
        let section = sections[section]
        if let height = section.footerHeight {
            return CGFloat(height)
        }
        return 0.0
    }
    
    public func heightForHeader(at section: Int) -> CGFloat {
        let section = sections[section]
        if let height = section.headerHeight {
            return CGFloat(height)
        }
        return 0.0
    }
    
    public func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        return row.height
    }
    
    public func tableViewCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath)
        cell.accessoryType = row.accessoryType
        cell.selectionStyle = row.selectionStyle
        
        for item in row.items {
            if item.type == .date {
                if let label = cell.contentView.viewWithTag(item.tag) as? UILabel {
                    label.isHidden = item.isHidden
                    if let value = item.display as? Date {
                        if let dateFormatter = item.dateFormatter {
                            label.text = dateFormatter.string(from: value)
                        } else {
                            label.text = value.description
                        }
                    } else {
                        label.text = "";
                    }
                    if let textColor = item.textColor {
                        label.textColor = textColor
                    }
                }
            } else if item.type == .UIPickerView {
                if let picker = cell.contentView.viewWithTag(item.tag) as? UIPickerView,
                    let selectedRow = item.display as? Int {
                    picker.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                
            } else if item.type == .UIDatePicker {
                if let picker = cell.contentView.viewWithTag(item.tag) as? UIDatePicker {
                    picker.maximumDate = item.maximumDate
                    picker.minimumDate = item.minimumDate
                    picker.minuteInterval = item.minuteInterval ?? 1
                    picker.datePickerMode = item.datePickerMode ?? UIDatePickerMode.dateAndTime
                    picker.date = item.display as? Date ?? Date()
                }
                
            } else if item.type == .UILabel {
                if let label = cell.contentView.viewWithTag(item.tag) as? UILabel {
                    label.isHidden = item.isHidden
                    label.textColor = item.textColor
                    if let display = item.display as? String {
                        label.text = display
                    }
                }
                
            } else if item.type == .textLabel {
                cell.textLabel?.textColor = item.textColor
                if let display = item.display as? String {
                    cell.textLabel?.text = display
                }
                
            } else if item.type == .UITextField {
                if let textField = cell.contentView.viewWithTag(item.tag) as? UITextField {
                    textField.autocorrectionType = item.autocorrectionType
                    textField.autocapitalizationType = item.autocapitalizationType
                    textField.isSecureTextEntry = item.isSecureTextEntry
                    textField.keyboardType = item.keyboardType
                    textField.placeholder = item.placeholder
                    textField.spellCheckingType = item.spellCheckingType
                    textField.textColor = item.textColor
                    if let display = item.display as? String {
                        textField.text = display
                    }
                }
                
            } else if item.type == .UITextView {
                if let textView = cell.contentView.viewWithTag(item.tag) as? UITextView {
                    textView.autocorrectionType = item.autocorrectionType
                    textView.autocapitalizationType = item.autocapitalizationType
                    textView.isSecureTextEntry = item.isSecureTextEntry
                    textView.keyboardType = item.keyboardType
                    textView.spellCheckingType = item.spellCheckingType
                    textView.textColor = item.textColor
                    if let display = item.display as? String {
                        textView.text = display
                    }
                }
                
            } else if item.type == .UISwitch {
                if let switchView = cell.viewWithTag(item.tag) as? UISwitch {
                    if let value = item.display as? Bool {
                        switchView.isOn = value
                    }
                }
                
            } else if item.type == .UISegmentedControl {
                if let control = cell.contentView.viewWithTag(item.tag) as? UISegmentedControl {
                    if let value = item.display as? Int {
                        control.selectedSegmentIndex = value
                    } else {
                        control.selectedSegmentIndex = 0
                    }
                }
            } else if item.type == .UIImageView {
                if let imageView = cell.contentView.viewWithTag(item.tag) as? UIImageView {
                    imageView.isHidden = item.isHidden
                }
            }
        }
        return cell
    }
    
    public func numberOfRows(in section: Int) -> Int {
        let section = sections[section]
        return section.rows.count
    }
    
    public func footerTitle(for section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    public func headerTitle(for section: Int) -> String? {
        return sections[section].headerTitle
    }
    
    // MARK: - Save
    
    func archivePath() -> String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("formData").path
    }
    
    public func archiveSections() {
        let filePath = self.archivePath()
        NSKeyedArchiver.archiveRootObject(sections, toFile: filePath)
    }
    
    public func unarchiveSections() {
        let filePath = self.archivePath()
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [FormSection] {
            self.sections = data
        }
    }
    
    public func deleteArchive() {
        let filePath = self.archivePath()
        let manager = FileManager.default
        if (manager.fileExists(atPath: filePath)) {
            do {
                try manager.removeItem(atPath: filePath)
            } catch let error as NSError {
                print("Failed to delete file \(error)")
            }
        }
    }
    
    public func save(value: Any?, display: Any?, forView view: UIView) {
        if let indexPath = indexPath(forView: view) {
            let row = sections[indexPath.section].rows[indexPath.row]
            for item in row.items where item.key != nil {
                item.display = display
                item.rawValue = value
            }
        }
    }
    
    public func save(value: Any?, forView view: UIView) {
        self.save(value: value, display: value, forView: view)
    }
    
    public func save(datePicker: UIDatePicker) {
        if let indexPath = indexPath(forView: datePicker) {
            let dateIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if let row = self.row(at: dateIndexPath),
                let items = row.items(withType: .date),
                let item = items.first {
                item.display = datePicker.date
                item.rawValue = datePicker.date
            }
            tableView.reloadRows(at: [dateIndexPath], with: .none)
        }
    }
    
    // MARK: - Validation
    
    public func isFilled() -> Bool {
        for section in sections {
            for row in section.rows {
                for item in row.items {
                    if item.isOptional {
                        continue
                    }
                    if item.key != nil && item.rawValue == nil {
                        return false
                    }
                }
            }
        }
        return true
    }
    
}
