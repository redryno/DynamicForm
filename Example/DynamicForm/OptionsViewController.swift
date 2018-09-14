//
//  OptionsViewController.swift
//  FormExample
//
//  Created by Ryan Bigger on 8/24/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

import UIKit
import DynamicForm

class OptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var formInfoFile: String?
    var formInfo = FormInfo()
    var selected: String?
    var callBack: ((_ display: String, _ value: String) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filename = formInfoFile {
            formInfo.load(filename: filename, for: tableView)
        }
        
        if selected != nil {
            formInfo.map { (section, row, item) in
                if let value = item.rawValue as? String {
                    if value == selected {
                        row.accessoryType = .checkmark
                    } else {
                        row.accessoryType = .none
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return formInfo.footerTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formInfo.headerTitle(for: section)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = formInfo.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        if let subview = row.items.first,
            let display = subview.display as? String,
            let value = subview.rawValue as? String {
            callBack?(display, value)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
