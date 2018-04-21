//
//  ViewController.swift
//  HandySolver
//
//  Created by Shubham Garg on 19/04/18.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit
import  CoreData
class ItemsViewController: UIViewController {

    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    /// Item entity Array
    private var items: [Item]?
    private var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Items"
        self.items = self.loadHosts()
        itemsTableView?.dataSource = self
        itemsTableView?.delegate = self
        self.itemsTableView?.tableFooterView = UIView(frame: .zero)
        self.addBtn.roundCorners([.allCorners], radius: self.addBtn.frame.width, borderColor: .clear, borderWidth: 0)
    }

    //Action on add button
    @IBAction func addBtnAxn(_ sender: Any) {
        let alert = UIAlertController(title: "Add an Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item detail"
        }
        alert.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { (action) -> Void in
            self.item = nil
            let textField = alert.textFields![0]
            self.saveData(itemName: textField.text!)
            self.items = self.loadHosts()
            self.itemsTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// Load data from core data
    private func loadHosts() -> [Item] {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Item", in: CoreDataStack.managedObjectContext) else {
            return [Item]()
        }
        
        let request = NSFetchRequest<Item>()
        request.entity = entityDescription
        
        do {
            let results = try CoreDataStack.managedObjectContext.fetch(request)
            return results
        } catch let error as NSError {
            let alert = UIAlertController(title: "Can't retrieve Item", message: error.description)
            present(alert, animated: true, completion: nil)
            return [Item]()
        }
    }
    
    //delete item
     func deleteItem(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure to delete item.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.item = self.items?[(sender as! UIButton).tag]
            self.deleteItem()
            self.items = self.loadHosts()
            self.itemsTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //edit item
    func editItem(_ sender: Any){
        let alert = UIAlertController(title: "Update Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = self.items?[(sender as! UIButton).tag].itemName
        }
        alert.addAction(UIAlertAction(title: "Update Item", style: .default, handler: { (action) -> Void in
            self.item = self.items?[(sender as! UIButton).tag]
            let textField = alert.textFields![0]
            self.saveData(itemName: textField.text!)
            self.items = self.loadHosts()
            self.itemsTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Delete item
    private func deleteItem() {
        if let item = self.item {
            CoreDataStack.managedObjectContext.delete(item)
            do {
                try CoreDataStack.managedObjectContext.save()
            } catch {
                let alert = UIAlertController(title: "Error", message: "Failed to delete Item")
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// Save or update item
    private func saveData(itemName: String) {
        if itemName.replacingOccurrences(of: " ", with: "") == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter a Item name")
            present(alert, animated: true, completion: nil)
            
            return
        }
        if let item = self.item {
            item.itemName = itemName
            CoreDataStack.saveContext()
            
        } else {
            if #available(iOS 10.0, *) {
                let item = Item(context: CoreDataStack.managedObjectContext)
                item.itemName = itemName
                item.uuid = UUID().uuidString
                
            } else {
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "Item", in: CoreDataStack.managedObjectContext) else {
                    return
                }
                let item = Item(entity: entityDescription, insertInto: CoreDataStack.managedObjectContext)
                item.itemName = itemName
                item.uuid = UUID().uuidString
            }
            
            CoreDataStack.saveContext()
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Number of rows
    ///
    /// - Parameters:
    ///   - tableView: the table
    ///   - section: the section index
    /// - Returns: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    /// Cell for index path
    ///
    /// - Parameters:
    ///   - tableView: the table view
    ///   - indexPath: the index path
    /// - Returns: Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.itemNameLbl.text = self.items?[indexPath.row].itemName
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    /// height for row
    ///
    /// - Parameters:
    ///   - tableView: the table view
    ///   - indexPath: the index path
    /// - Returns: Cell Height
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// estimated height for row
    ///
    /// - Parameters:
    ///   - tableView: the table view
    ///   - indexPath: the index path
    /// - Returns: Cell Height
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

/**
 * Item cell
 *
 * - author: SHUBHAM GARG
 */
class ItemCell: UITableViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemView: UIView!
    
    var delegate: ItemsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemView.setNeedsLayout()
        itemView.setCirculerViewWithBorder(radis: 0, borderColor: .black, borderWidth: 2)
    }
    
    //Action on delete button
    @IBAction func deleteBtnAxn(_ sender: Any) {
        delegate?.deleteItem(sender)
    }
    
    //Action on edit button
    @IBAction func editBtnAxn(_ sender: Any) {
        delegate?.editItem(sender)
    }
    
}
