//
//  TaskDetailViewController.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/21/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController, StoryboardInstantiatable {
    
    static var storyboardName: StoryboardName = "TaskDetailViewController"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 90
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifier")
    }
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapSettingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SettingsTableViewController", bundle: nil)
        let settingsVC = storyboard.instantiateInitialViewController() ?? SettingsTableViewController.instantiate()
        present(settingsVC, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapSendButton(_ sender: Any) {
    }
    
}

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
        return cell
    }
    
}
