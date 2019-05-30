//
//  Task.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct TaskList: Codable {
    let data: [Task]
}

class Task: Codable {
    var id: Int?
    var taskName: String // Should have a value
    var taskDescription: String?
    var completed: Bool?
    var completedBy: Int? // User id
    var completedOn: Date?
    var groupID: Int // Should have a value
    var assigneeName: String?
    var createdBy: String? // Current User name
    var recurringTime: String?
    var numberOfComments: Int?
    
    init(id: Int? = nil,
         taskName: String,
         taskDescription: String? = nil,
         completed: Bool? = nil,
         completedBy: Int? = nil,
         completedOn: Date? = nil,
         group: Group,
         assigneeName: String? = nil,
         createdBy: String? = nil,
         recurringTime: String? = nil,
         numberOfComments: Int? = 0) {
        
        self.id = id
        self.taskName = taskName
        self.taskDescription = taskDescription
        self.completed = completed
        self.completedBy = completedBy
        self.completedOn = completedOn
        self.groupID = group.groupID
        self.assigneeName = assigneeName
        self.createdBy = createdBy
        self.recurringTime = recurringTime
        self.numberOfComments = numberOfComments
    }
}

extension Task: Equatable {
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.taskName == rhs.taskName &&
            lhs.groupID == rhs.groupID &&
            lhs.id == rhs.id
    }
    
}
