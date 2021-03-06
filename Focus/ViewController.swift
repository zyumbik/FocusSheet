//
//  ViewController.swift
//  Focus
//
//  Created by Gleb Sabirzyanov on 04/12/2017.
//  Copyright © 2017 Gleb Sabirzyanov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var tableView: FocusSheetTableView!
    
    var data: [FocusItem] = MyData().data
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Set the table view data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
//        Set table row height
        self.tableView.rowHeight = FSTableRowHeight.small
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return FocusSheetTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var view: FocusSheetTableCellView
        
        if data.count == row {
//            Empty task item
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "taskCell"), owner: self) as! FocusSheetTaskCellView
            view.checkbox.isHidden = true
            view.otherLabel.stringValue = ""
            view.nameLabel.stringValue = ""
        } else if let challenge = data[row] as? ChallengeItem {
//            Challenge item
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "challengeCell"), owner: self) as! FocusSheetChallengeCellView
            
            view.otherLabel.stringValue = challenge.strDayOfDays
            
        } else if let task = data[row] as? TaskItem {
//            Task item
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "taskCell"), owner: self) as! FocusSheetTaskCellView
            
            view.otherLabel.stringValue = "3 days ago"
            
        } else {
            return nil
        }
        
        view.cellDelegate = self
        view.nameLabel.font = NSFontManager.shared.convert(view.nameLabel.font!, toHaveTrait: .boldFontMask)
        
        guard data.count > row else {
            return view as? NSView
        }
        
        view.nameLabel.stringValue = data[row].name
        view.checkbox.state = data[row].isDone ? NSControl.StateValue.on : NSControl.StateValue.off
        
        return view as? NSView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        tableView.reloadData(forRowIndexes: IndexSet(integersIn: row-1...row+1),
                             columnIndexes: IndexSet(integer: 0))
    }
    
}

extension ViewController: FocusSheetTableCellDelegate {
   
    func onStateChange(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard row >= 0 else { return }
        if sender.state == NSControl.StateValue.on {
            data[row].isDone = true
        } else {
            data[row].isDone = false
        }
        print("State changed.")
    }
    
    func onNameChange(_ sender: NSTextField) {
        let row: Int = tableView.row(for: sender)
        guard row >= 0 else { return }
        if data.count > row {
            data[row].name = sender.stringValue
            print(data[row].name)
        } else {
            if sender.stringValue != "" {
                data.append(TaskItem(name: sender.stringValue, dateAdded: Date()))
                tableView.beginUpdates()
                tableView.insertRows(at: IndexSet(integer: tableView.numberOfRows - 1), withAnimation: .effectFade)
                print(tableView.numberOfRows)
                tableView.endUpdates()
                tableView.reloadData(forRowIndexes: IndexSet(integer: tableView.numberOfRows - 1),
                                     columnIndexes: IndexSet(integer: 0))
            }
        }
    }
    
}

