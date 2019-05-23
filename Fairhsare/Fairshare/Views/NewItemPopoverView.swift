//
//  NewItemPopoverView.swift
//  ShoppingList
//
//  Created by Jason Modisett on 2/28/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class NewItemPopoverView: UIView, NibInstantiatable {
    
    static let nibName: NibName = "NewItemPopoverView"
    weak var delegate: PopoverViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemName.becomeFirstResponder()
    }
    
    @IBAction func addItemPressed(_ sender: Any) {
        guard let name = itemName.text else { return }
        guard let selectedGroup = selectedGroup else { return }
        guard let user = userObject else { return }
        
        switch globalCurrentView {
        case .chore:
            let task = Task(id: nil, taskName: name, taskDescription: nil, completed: nil, completedBy: nil, completedOn: nil, group: selectedGroup, assigneeName: nil, createdBy: user.name)
            ItemController.shared.saveTask(task: task) { (task, _) in
                self.delegate?.updatesNeeded()
                popover.dismiss()
            }
        case .grocery:
            let item = Item(name: name, measurement: nil, purchased: false, price: 0, quantity: 0, group: selectedGroup)
            ItemController.shared.saveItem(item: item) { (item, _) in
                self.delegate?.updatesNeeded()
                popover.dismiss()
            }
        case .history:
            break
        case .stats:
            break
        }
    }
    
    @IBOutlet weak var itemName: UITextField!
    
}
