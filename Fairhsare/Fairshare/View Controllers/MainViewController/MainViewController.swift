//
//  MainViewController.swift
//  Shopping List
//
//  Created by Jason Modisett on 2/14/19.
//  Copyright © 2019 Jason Modisett. All rights reserved.
//

import UIKit
import Auth0
import PushNotifications

enum GroupView { case chore, grocery, history, stats }
var globalCurrentView: GroupView = .chore

class MainViewController: UIViewController, StoryboardInstantiatable, PopoverViewDelegate {
    
    static let storyboardName: StoryboardName = "MainViewController"
    var noItemsView: NoItemsView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewItemContainer: UIView!
    @IBOutlet weak var checkoutContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var checkoutCountView: UIView!
    @IBOutlet weak var checkoutCountLabel: UILabel!
    @IBOutlet weak var addNewButton: UIButton!
    
    var currentView: GroupView = .chore { didSet { updatesNeeded() }}
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkoutCountView.layer.cornerRadius = checkoutCountView.frame.height / 2
        
        noItemsView = NoItemsView.instantiate()
        noItemsView.frame = tableView.frame
        view.insertSubview(noItemsView, aboveSubview: tableView)
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifier")
        tableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        
        GroupController.shared.getUserID { (user) in
            
            guard let id = user?.profile.id,
                let name = user?.profile.name else { return }
            
            userID = id
            userName = name
            
            UserController.shared.getUser(forID: id, completion: { (_) in })
            
            GroupController.shared.getGroups(forUserID: userID, pusher: PushNotifications.shared) { (success) in
                if allGroups.count > 0 {
                    selectedGroup = allGroups[0]
                    UI { self.updatesNeeded() }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func segmentControlSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentView = .chore
            globalCurrentView = .chore
        case 1:
            currentView = .grocery
            globalCurrentView = .grocery
        case 2:
            currentView = .history
            globalCurrentView = .history
        default:
            currentView = .chore
            globalCurrentView = .chore
        }
    }
    
    
    
    func updatesNeeded() {
        noItemsView.alpha = 0
        noItemsView.groupView = currentView
        checkoutContainer.alpha = 0
        
        switch currentView {
        case .chore:
            ItemController.shared.loadTasks { (_) in
                UI {
                    self.addNewButton.setTitle("Add chore", for: .normal)
                    self.tableView.rowHeight = 90
                    self.addNewItemContainer.alpha = 1
                    self.tableView.reloadData()
                }
            }
        case .grocery:
            ItemController.shared.loadItems { (_) in
                UI {
                    self.addNewButton.setTitle("Add grocery", for: .normal)
                    self.tableView.rowHeight = 90
                    self.addNewItemContainer.alpha = 1
                    self.tableView.reloadData()
                }
            }
        case .history:
            ItemController.shared.loadItems { (_) in
                HistoryController().getHistory { (_) in
                    UI {
                        self.tableView.rowHeight = 120
                        self.addNewItemContainer.alpha = 0
                        self.tableView.reloadData()
                    }
                }
            }
        case .stats:
            GroupMemberController().getGroupMembers { (_) in
                UI {
                    self.addNewItemContainer.alpha = 0
                    self.tableView.reloadData()
                }
            }
        }
        
        guard let selectedGroup = selectedGroup else { return }
        selectedItems = []
        groupName.text = selectedGroup.name
    }
    
    
    // MARK: - IBActions
    
    @IBAction func scanBarcodePressed(_ sender: Any) {
        let barcodeVC = BarcodeScannerController.instantiate()
        barcodeVC.delegate = self
        present(barcodeVC, animated: true, completion: nil)
    }
    
    @IBAction func addNewItemButtonPressed(_ sender: Any) {
        Popovers.triggerNewItemPopover(self)
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        Popovers.triggerCheckoutPopover(delegate: self, items: selectedItems)
    }
    
    
    @IBAction func showGroupsButtonPressed(_ sender: Any) {
        Popovers.triggerGroupsPopover(self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SettingsTableViewController", bundle: nil)
        let settingsVC = storyboard.instantiateInitialViewController() ?? SettingsTableViewController.instantiate()
        present(settingsVC, animated: true, completion: nil)
    }
}


extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentView {
        case .chore:
            noItemsView.alpha = (selectedGroup?.tasks?.count ?? 0) == 0 ? 1 : 0
            return selectedGroup?.tasks?.count ?? 0
        case .grocery:
            noItemsView.alpha = (selectedGroup?.items?.count ?? 0) == 0 ? 1 : 0
            return selectedGroup?.items?.count ?? 0
        case .history:
            noItemsView.alpha = history.count == 0 ? 1 : 0
            return history.count
        case .stats:
            noItemsView.alpha = groupMembers.count == 0 ? 1 : 0
            return groupMembers.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
        
        guard let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemTableViewCell,
            let historyCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else { return cell }
        
        itemCell.tintColor = UIColor(named: "Theme")
        itemCell.accessoryType = .none
        historyCell.accessoryType = .none
        cell.tintColor = UIColor(named: "Theme")
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .none
        guard let selectedGroup = selectedGroup else { return cell }
        
        switch currentView {
        case .chore:
            guard let task = selectedGroup.tasks?[indexPath.row] else { return cell }
            itemCell.accessoryType = selectedTasks.contains(task) ? .checkmark : .none
            itemCell.itemLabel.text = task.taskName
            return itemCell
        case .grocery:
            guard let item = selectedGroup.items?[indexPath.row] else { return cell }
            itemCell.accessoryType = selectedItems.contains(item) ? .checkmark : .none
            itemCell.itemLabel.text = item.name
            return itemCell
        case .history:
            let item = history[indexPath.row]
            let itemName = item.name ?? ""
            let itemUser = item.user ?? ""
            let total = item.total?.toCurrency() ?? ""
            historyCell.itemLabel.text = itemName
            historyCell.nameLabel.text = itemUser.uppercased()
            historyCell.priceLabel.text = total
            return historyCell
        case .stats:
            let groupMember = groupMembers[indexPath.row]
            let total = groupMember.total.toCurrency()
            let net = groupMember.net.toCurrency()
            cell.textLabel?.text = "Total: \(total)\nNet: \(net)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentView {
        case .chore:
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "TaskDetailViewController", bundle: nil)
            let taskDetailVC = storyboard.instantiateInitialViewController() ?? TaskDetailViewController.instantiate()
            
            if let taskDVC = taskDetailVC as? TaskDetailViewController {
                taskDVC.task = selectedGroup?.tasks?[indexPath.row]
            }
            present(taskDetailVC, animated: true, completion: nil)
        case .grocery:
            tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            cellSelected(cell: cell, indexPath: indexPath)
        case .history, .stats:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let selectedGroup = selectedGroup else { return }
            
            switch self.currentView {
            case .chore:
                guard let task = selectedGroup.tasks?[indexPath.row] else { return }
                
                ItemController.shared.deleteTask(id: task.id ?? 0) {(_) in }
                if selectedTasks.contains(task) {
                    let index = selectedTasks.index(of: task) ?? 0
                    selectedItems.remove(at: index)
                }
                
                selectedGroup.tasks?.remove(at: indexPath.row)
            case .grocery:
                guard let item = selectedGroup.items?[indexPath.row] else { return }
                
                ItemController.shared.deleteItem(id: item.id ?? 0) {(_) in }
                if selectedItems.contains(item) {
                    let index = selectedItems.index(of: item) ?? 0
                    selectedItems.remove(at: index)
                }
                
                selectedGroup.items?.remove(at: indexPath.row)
            case .history, .stats:
                break
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return currentView == .history ? [] : [delete]
    }
    
    private func cellSelected(cell: UITableViewCell, indexPath: IndexPath) {
        switch currentView {
        case .chore:
            break
        case .grocery:
            guard let item = selectedGroup?.items?[indexPath.row] else { return }
            if cell.accessoryType == .none {
                selectedItems.append(item)
                cell.accessoryType = .checkmark
            } else {
                let index = selectedItems.index(of: item) ?? 0
                selectedItems.remove(at: index)
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        if currentView == .chore || currentView == .grocery {
            let showCheckout = selectedItems.count > 0
            addNewItemContainer.alpha = showCheckout ? 0 : 1
            checkoutContainer.alpha = showCheckout ? 1 : 0
            checkoutCountLabel.text = "\(selectedItems.count)"
        }
    }
    
}
