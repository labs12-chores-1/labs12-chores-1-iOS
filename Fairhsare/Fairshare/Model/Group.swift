//
//  Group.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct GroupsList: Codable {
    let groups: [Group]
}


class Group: Codable, Equatable {
    
    var name: String
    var groupID: Int
    var token: String?
    var userID: Int
    
    var createdAt: String
    var updatedAt: String
    
    var memberAmount: Int?
    
    var groupMembers: [GroupMember]?
    var trips: [Trip]?
    var items: [Item]? // api/group/id
    var tasks: [Task]? // api/group/id
    var comments: [Comment]?
    var users: [User] = [User(email: "", name: "Adalberto May", profilePicture: ""),
                         User(email: "", name: "Estevan Rodriguez", profilePicture: ""),
                         User(email: "", name: "Ilqar Ilyasov", profilePicture: ""),
                         User(email: "", name: "Itel Domingo", profilePicture: ""),
                         User(email: "", name: "Joseph Chretien-Golden", profilePicture: ""),
                         User(email: "", name: "Tsai Huang", profilePicture: "")]
    
    enum CodingKeys: String, CodingKey {
        case name
        case groupID = "id"
        case token
        case userID
        
        case createdAt
        case updatedAt
        
        case memberAmount
    }
    
    
    init(name: String, userID: Int, token: String, groupID: Int) {
        
        self.name = name

        self.userID = userID
        
        self.createdAt = Date().dateToString()
        self.updatedAt = Date().dateToString()
        
        self.memberAmount = 1
        self.token = token
        
        self.groupID = groupID
    }
}

extension Group {
    
    static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.name == rhs.name &&
            lhs.groupID == rhs.groupID
    }
    
}

