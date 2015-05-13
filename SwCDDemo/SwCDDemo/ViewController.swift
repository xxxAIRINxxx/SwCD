//
//  ViewController.swift
//  SwCD
//
//  Created by xxxAIRINxxx on 2015/05/01.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import SwCD

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwCD.setup("DemoModel", dbRootDirPath: nil, dbDirName: "Demo", dbName: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapAdd() {
        var item = SwCD.createEntity(Item.self)
        item.identifier = NSUUID().UUIDString
        item.name = "item"
        item.created = NSDate()
        SwCD.insert(Item.self, entities: [item], completion: {success, error in
            if success == true {
                self.tableView.reloadData()
            } else {
                if let _error = error {
                    println(_error)
                }
            }
        })
    }
    
    @IBAction func tapDelete() {
        let items = SwCD.all(Item.self, sortDescriptors: [NSSortDescriptor(key: "identifier", ascending: true)])
        if items.count > 0 {
            let item = items.first!
            SwCD.delete(Item.self, entities: [item], completion: {success, error in
                if success == true {
                    self.tableView.reloadData()
                } else {
                    if let _error = error {
                        println(_error)
                    }
                }
            })
        }
    }

    @IBAction func tapDeleteAll() {
        SwCD.deleteAll(Item.self, completion: {success, error in
            if success == true {
                self.tableView.reloadData()
            } else {
                if let _error = error {
                    println(_error)
                }
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SwCD.all(Item.self, sortDescriptors: [NSSortDescriptor(key: "identifier", ascending: true)]).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let item = SwCD.all(Item.self, sortDescriptors: [NSSortDescriptor(key: "identifier", ascending: true)])[indexPath.row]
        cell.textLabel!.text = item.identifier
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = SwCD.all(Item.self, sortDescriptors: [NSSortDescriptor(key: "identifier", ascending: true)])[indexPath.row]
        SwCD.delete(Item.self, entities: [item], completion: {success, error in
            if success == true {
                self.tableView.reloadData()
            } else {
                if let _error = error {
                    println(_error)
                }
            }
        })
    }
}

