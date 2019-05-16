//
//  NoItemsView.swift
//  ShoppingList
//
//  Created by Jason Modisett on 3/7/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class NoItemsView: UIView, NibInstantiatable {
    
    static let nibName: NibName = "NoItemsView"
    var groupView: GroupView? = nil { didSet { updateViews() }}
    
    private func updateViews() {
        guard let groupView = groupView else { return }
        switch groupView {
        case .chore:
            textLabel.text = "No chores to complete in this group"
        case .grocery:
            textLabel.text = "No grocery to buy in this group"
        case .history:
            textLabel.text = "Nothing completed yet"
        case .stats:
            textLabel.text = ""
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!
    
}
