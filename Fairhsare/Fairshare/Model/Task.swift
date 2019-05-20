//
//  Task.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class Task: Codable {
    var id: Int?
    var taskName: String // Should have a value
    var description: String?
    var completed: Bool?
    var completedBy: Int? // User id
    var completedOn: Date?
    var groupID: Int // Should have a value
    
    init(id: Int? = nil,
         taskName: String,
         description: String? = nil,
         completed: Bool? = nil,
         completedBy: Int? = nil,
         completedOn: Date? = nil,
         group: Group) {
        
        self.id = id
        self.taskName = taskName
        self.description = description
        self.completed = completed
        self.completedBy = completedBy
        self.completedOn = completedOn
        self.groupID = group.groupID
    }
}

extension Task: Equatable {
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.taskName == rhs.taskName &&
            lhs.groupID == rhs.groupID &&
            lhs.id == rhs.id
    }
    
}
