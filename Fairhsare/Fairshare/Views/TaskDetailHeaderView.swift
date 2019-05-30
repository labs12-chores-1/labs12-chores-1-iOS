//
//  TaskDetailHeaderView.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/24/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation



class TaskDetailHeaderView: UIView, NibInstantiatable, UITextViewDelegate, PopoverViewDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionTextView.delegate = self
        delegate = self
    }
    
    static var nibName: NibName = "TaskDetailHeaderView"
    weak var delegate: PopoverViewDelegate?
    @IBOutlet weak var createdByTextField: UITextField!
    @IBOutlet weak var assignedToTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var task: Task? {
        didSet { updateViews() }
    }
    
    private func updateViews() {
        guard let task = task else { return }
        
        createdByTextField.text = task.createdBy
        assignedToTextField.text = task.assigneeName ?? "No one"
        descriptionTextView.text = task.taskDescription ?? ""
    }
    
    func updatesNeeded() {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text,
            let task = task else { return }
        
        task.taskDescription = text
        ItemController.shared.saveTask(task: task) { (_, _) in }
    }
    
    @IBAction func didTouchUpInsideCreatedBy(_ sender: UITextField) {
        Popovers.triggerUsersPopover(self)
    }
    
    @IBAction func didTouchUpInsideAssignedTo(_ sender: UITextField) {
        Popovers.triggerUsersPopover(self)
    }
    
}
