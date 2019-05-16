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
    let taskName: String
    let description: String?
    let completed: Bool?
    let completedBy: Int?
    let completedOn: Date?
    let groupID: Int
    
    init(id: Int?,
         taskName: String,
         description: String?,
         completed: Bool?,
         completedBy: Int?,
         completedOn: Date?,
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
