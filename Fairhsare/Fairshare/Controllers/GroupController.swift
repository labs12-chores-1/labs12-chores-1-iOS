//
//  GroupController.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/14/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import Auth0
import PusherSwift
import PushNotifications

class GroupController {
    
    struct Profile: Codable {
        let profile: User
    }
    
    struct User: Codable {
        let id: Int
        let name: String
    }
    
    struct Param: Codable {
        let userID: Int
        let name: String
        let token: String
    }
    
    static let shared = GroupController()
    // http://localhost:9000/api
    private var baseURL = URL(string: "https://labs12-fairshare.herokuapp.com/api")!
    
    func getUserID(completion: @escaping (Profile?) -> Void) {
//        let user = User(id: 1, name: "Ilqar Ilyasov")
//        let profile = Profile(profile: user)
//        completion(profile)
        
        guard let accessToken = SessionManager.tokens?.idToken else {return}

        let url = baseURL.appendingPathComponent("user").appendingPathComponent("check").appendingPathComponent("getid")
//        let url = baseURL.appendingPathComponent("user").appendingPathComponent("1")
        var request = URLRequest(url: url)

        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                NSLog("getUserID Error: \(error)")
                completion(nil)
                return
            }

            if let response = response as? HTTPURLResponse {
                NSLog("getUserID Response: \(response.statusCode)")
            }

            guard let data = data else {
                NSLog("getUserID No data returned")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(Profile.self, from: data)
                completion(user)
            } catch {
                print("Could not turn json into user")
                completion(nil)
                return
            }
        }.resume()
    }
    
    
    
    
    private func groupToJSON(group: Group) -> [String: Any]? {
        
        guard let jsonData = try? JSONEncoder().encode(group) else {
            return nil
        }
        
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            return jsonDict
        } catch {
            return nil
        }
    }
    
    
    func newGroup(withName name: String, completion: @escaping (Group?) -> Void) {
        
//        let groupID = getRandomNumber()
//        let group = Group(name: name, userID: userID, token: "123", groupID: groupID)
//        completion(group)
        
        guard let accessToken = SessionManager.tokens?.idToken else {return}

        self.getUserID { (id) in

            guard let userID = id?.profile.id else { completion(nil); return }

            let url = self.baseURL.appendingPathComponent("group")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let params = Param(userID: userID, name: name, token: accessToken)

            do {
                let encoder = JSONEncoder()
                let body = try encoder.encode(params)
                request.httpBody = body

            } catch {
                print("Could not turn params into json")
                return
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in

                if let error = error {
                    NSLog("newGroup Error: \(error)")
                    completion(nil)
                    return
                }

                if let response = response as? HTTPURLResponse{
                    NSLog("newGroup Response: \(response.statusCode)")
                }

                guard let data = data else {
                    NSLog("newGroup No data")
                    completion(nil)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let group = try decoder.decode(Group.self, from: data)
                    completion(group)
                } catch {
                    NSLog("newGroup Couldn't turn json to Group")
                    completion(nil)
                }
                }.resume()
        }
    }
    
    
    // Updates the group and downloads all groups from server. Optional success completion.
    func updateGroup(
        group: Group,
        name: String?,
        userID: Int?,
        pusher: PushNotifications,
        completion: @escaping (Bool) -> Void = {_ in }
    ) {
        
        guard let accessToken = SessionManager.tokens?.idToken else {return}
        let headers: HTTPHeaders = [ "Authorization": "Bearer \(accessToken)"]
        
        let myGroup = group
        
        if let name = name {
            myGroup.name = name
        }
        
        if let userID = userID {
            myGroup.userID = userID
        }
        
        myGroup.updatedAt = Date().dateToString()
        
        let url = baseURL.appendingPathComponent("group").appendingPathComponent(String(myGroup.groupID))
        
        guard let groupJSON = groupToJSON(group: myGroup) else { return }
        
        Alamofire.request(url, method: .put, parameters: groupJSON, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(_):
                
                // This downloads allGroups from server so we have fresh data
                self.getGroups(forUserID: userID!, pusher: pusher, completion: { (success) in
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
                return
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
                return
            }
        }
    }
    
    // Gets groups from server and updates the singleton. Optional success completion
    func getGroups(
        forUserID userID: Int,
        pusher: PushNotifications,
        completion: @escaping (Bool) -> Void = { _ in }
        ) {
        
//        let group = Group(name: "Demo", userID: 1, token: "123", groupID: 1)
//        let list = GroupsList(groups: [group])
//        allGroups = list.groups
//        completion(true)
        
        guard let accessToken = SessionManager.tokens?.idToken else {return}
        
        let url = baseURL.appendingPathComponent("group").appendingPathComponent("user").appendingPathComponent(String(userID))
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("getGroups Error: \(error)")
                completion(false)
                return
            }

            if let response = response as? HTTPURLResponse {
                NSLog("getGroups Response: \(response.statusCode)")
            }

            guard let data = data else {
                NSLog("getGroups No data")
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                let groups = try decoder.decode(GroupsList.self, from: data)

                allGroups = groups.groups

                for group in groups.groups {
                    let chan = "group-\(group.groupID)"
                    try! PushNotifications.shared.addDeviceInterest(interest:chan)
                }
                completion(true)
            } catch {
                print("Error getting groups from API response\(error)")
                completion(false)
                return
            }
        }.resume()
    }
    
    func delete(group: Group, completion: @escaping (Bool) -> Void) {
        guard let accessToken = SessionManager.tokens?.idToken else {return}
        let headers: HTTPHeaders = [ "Authorization": "Bearer \(accessToken)"]
        
        let url = baseURL.appendingPathComponent("group").appendingPathComponent("remove").appendingPathComponent("\(group.groupID)").appendingPathComponent("\(userID)")
        print(url)
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().response { (response) in
            
            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
}
