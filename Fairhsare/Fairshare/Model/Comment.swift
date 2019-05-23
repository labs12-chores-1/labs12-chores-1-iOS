//
//  Comment.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct CommentList: Codable {
    let data: [Comment]
}

class Comment: Codable {
    var id: Int?
    var commentString: String
    var taskID: Int
    var groupID: Int
    var commentedBy: Int // User
    var commentedOn: String?
    
    init(id: Int? = nil,
         commentString: String,
         taskID: Int,
         groupID: Int,
         commentedBy: Int,
         commentedOn: String? = nil) {
        
        self.id = id
        self.commentString = commentString
        self.taskID = taskID
        self.groupID = groupID
        self.commentedBy = commentedBy
        self.commentedOn = commentedOn
    }
}

extension Comment: Equatable {
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id &&
            lhs.taskID == rhs.taskID &&
            lhs.groupID == rhs.groupID &&
            lhs.commentedBy == rhs.commentedBy
    }
    
}
