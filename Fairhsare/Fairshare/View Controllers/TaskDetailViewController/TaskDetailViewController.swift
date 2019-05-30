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
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var taskTitleLabel: UILabel!
    var noTaskDetailView: NoTaskDetailView!
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        noTaskDetailView = NoTaskDetailView.instantiate()
        noTaskDetailView.frame = tableView.frame
        view.insertSubview(noTaskDetailView, aboveSubview: tableView)
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifier")
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        guard let taskID = task?.id else { return }
        ItemController.shared.loadComments(taskID: taskID, completion: { (success) in
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let task = task {
            taskTitleLabel.text = task.taskName
        }
    }
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapSendButton(_ sender: Any) {
        guard let commentString = commentTextField.text else { return }
        guard let group = selectedGroup else { return }
        guard let userID = userObject?.userID else { return }
        guard let taskID = task?.id else { return }
        
        let comment = Comment(commentString: commentString, taskID: taskID,
                              groupID: group.groupID, commentedBy: userID)
        
        ItemController.shared.saveComment(comment: comment) { (comment, error) in
            if let error = error {
                NSLog("Error creating comment: \(error)")
            }
            
            if let comment = comment {
                selectedGroup?.comments?.append(comment)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.commentTextField.text = ""
                }
            }
        }
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
}

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noTaskDetailView.alpha = (selectedGroup?.comments?.count ?? 0) == 0 ? 1 : 0 //selectedGroup?.
        return selectedGroup?.comments?.count ?? 0 // selectedGroup?.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
        cell.tintColor = UIColor(named: "Theme")
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .none
        
        guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return cell }
        commentCell.tintColor = UIColor(named: "Theme")
        commentCell.accessoryType = .none
        commentCell.selectionStyle = .none
//        commentCell.backgroundColor = #colorLiteral(red: 0.9671966434, green: 0.9614465833, blue: 0.9716162086, alpha: 1)
        
        let comment = selectedGroup?.comments?[indexPath.row]
        commentCell.commentStringLabel.text = comment?.commentString
        
        if let commentedOn = comment?.commentedOn {
            let commentedOnDate = commentedOn.stringToDate()
            commentCell.commentedOnLabel.text = formatter.string(from: commentedOnDate)
        }
        
        if let name = userObject?.name {
            commentCell.commentedByLabel.text = name
        }
        
        return commentCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            guard let selectedGroup = selectedGroup else { return }
            guard let userID = userObject?.userID else { return }
            guard let comment = selectedGroup.comments?[indexPath.row] else { return }
            
            ItemController.shared.deleteComment(id: comment.id, completion: { (error) in
                if let error = error {
                    NSLog("Error deleting comment: \(error)")
                } else {
                    if comment.commentedBy == userID {
                        selectedGroup.comments?.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            })
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TaskDetailHeaderView.instantiate() as TaskDetailHeaderView
        
        if let task = task {
            headerView.task = task
        }
        
        headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 160)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
}
