//
//  Task.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class Task:Codable {
    let id: Int?
    let taskName: String // Should have a value
    let description: String?
    let completed: Bool?
    let completedBy: Int? // User id
    let completedOn: Date?
    let groupID: Int // Should have a value
    
    init(id: Int? = nil,
         taskName: String,
         description: String? = nil,
         completed: Bool? = nil,
         completedBy: Int? = nil,
         completedOn: Date? = nil,
         groupID: Int) {
        
        self.id = id
        self.taskName = taskName
        self.description = description
        self.completed = completed
        self.completedBy = completedBy
        self.completedOn = completedOn
        self.groupID = groupID
    }
}

extension Task: Equatable {
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.taskName == rhs.taskName &&
            lhs.groupID == rhs.groupID &&
            lhs.id == rhs.id
    }
    
}
