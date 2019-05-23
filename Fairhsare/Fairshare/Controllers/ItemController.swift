//
//  ItemController.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/14/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation
import Alamofire
import Auth0

enum ItemError: Error {
    case noIdReturned
    case backendError(String, Error)
}

class ItemController {
    
    private var baseURL = URL(string: "https://labs12-fairshare.herokuapp.com/api")!
    static let shared = ItemController()
    
    // MARK: - Loading GET
    
    // Loads items for the selected group
    func loadItems(completion: @escaping (Bool) -> Void = {_ in}) {
        
        guard let group = selectedGroup else { completion(false); return }
        guard let accessToken = SessionManager.tokens?.idToken else {return}

//        let url = baseURL.appendingPathComponent("item").appendingPathComponent("group").appendingPathComponent(String(group.groupID))
        let url = baseURL.appendingPathComponent("item")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        Alamofire.request(request).validate().response { (response) in

            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
                return
            }

            guard let data = response.data else {
                print("Error: No data when trying to load items")
                completion(false)
                return
            }

            do {
                let itemList = try JSONDecoder().decode(ItemList.self, from: data)
                let items = itemList.data

                group.items = nil
                var myHistory: [History] = []

                for item in items {
                    if item.groupID == group.groupID && !item.purchased {
                        if group.items != nil {
                            group.items?.append(item)
                        } else {
                            group.items = [item]
                        }
                    }

                    if item.purchased && item.groupID == group.groupID {
                        myHistory.append(History(item: item))
                    }
                }

                history = myHistory
                completion(true)

            } catch {
                print("Error: Could not decode data into [Item]")
                completion(false)
                return
            }
        }
    }
    
    // Loads tasks for the selected group
    func loadTasks(completion: @escaping (Bool) -> Void = {_ in}) {
        
        guard let group = selectedGroup else { completion(false); return }
        guard let accessToken = SessionManager.tokens?.idToken else {return}
        
        let url = baseURL.appendingPathComponent("task")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).validate().response { (response) in
            
            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            guard let data = response.data else {
                print("Error: No data when trying to load items")
                completion(false)
                return
            }
            
            do {
                let taskList = try JSONDecoder().decode(TaskList.self, from: data)
                group.tasks = [Task]() // Initiliaze array with empty value
                
                for task in taskList.data {
                    if task.createdBy == userObject?.name { // Check the owner of task
                        
                        if let result = group.tasks?.contains(task) {
                            switch result {
                            case true: // If it's already inside of our local array do not do anything
                                break
                            case false: // If task is a new task then add it to the array
                                group.tasks?.append(task)
                            }
                        }
                    }
                }
                
                completion(true)
            } catch {
                print("Error: Could not decode data into [Item]")
                completion(false)
                return
            }
        }
    }
    
    
    func loadComments(taskID: Int, completion: @escaping (Bool) -> Void = {_ in}) {
        
        guard let group = selectedGroup else { completion(false); return }
        guard let accessToken = SessionManager.tokens?.idToken else {return}
        
        let url = baseURL.appendingPathComponent("comment")
            .appendingPathComponent("task")
            .appendingPathComponent("\(taskID)")
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).validate().response { (response) in
            
            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            guard let data = response.data else {
                print("Error: No data when trying to load items")
                completion(false)
                return
            }
            
            do {
                let commentList = try JSONDecoder().decode(CommentList.self, from: data)
                group.comments = [Comment]() // Initiliaze array with empty value
                
                for comment in commentList.data {
                    if comment.commentedBy == userObject?.userID { // Check the owner of task
                        
                        if let result = group.comments?.contains(comment) {
                            switch result {
                            case true: // If it's already inside of our local array do not do anything
                                break
                            case false: // If task is a new task then add it to the array
                                group.comments?.append(comment)
                            }
                        }
                    }
                }
                
                completion(true)
            } catch {
                print("Error: Could not decode data into [CommentList]: \(error)")
                completion(false)
                return
            }
        }
    }
    
    
    // MARK:- Saving POST
    
    func saveItem(item: Item, completion: @escaping (Item?, Error?) -> Void) {
        
//        item.id = getRandomNumber()
//        completion(item, nil)
        
        guard let accessToken = SessionManager.tokens?.idToken else { return }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let item = item

        var url = baseURL.appendingPathComponent("item")

        var method = HTTPMethod.post

        if let id = item.id {
            url = url.appendingPathComponent(String(describing: id))
            method = .put
        }

        var json: Parameters

        do {
            json = try itemToJSON(item: item)
        }
        catch {
            completion(nil, error)
            return
        }

        Alamofire.request(url, method: method, parameters: json, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in

            switch response.result {
            case .success(let value):
                guard let jsonDict = value as? [String: Any],
                    let itemID = jsonDict["id"] as? Int else {
                        completion(nil, ItemError.noIdReturned)
                        return
                }

                item.id = itemID
                completion(item, nil)

            case .failure(let error):
                completion(nil, ItemError.backendError(String(data: response.data!, encoding: .utf8 )!, error))
                return
            }
        }
    }
    
    func saveTask(task: Task, completion: @escaping (Task?, Error?) -> Void) {

//        task.id = getRandomNumber()
//        completion(task, nil)

        guard let accessToken = SessionManager.tokens?.idToken else { return }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let task = task

        var url = baseURL.appendingPathComponent("task")

        var method = HTTPMethod.post

        if let id = task.id {
            url = url.appendingPathComponent(String(describing: id))
            method = .put
        }

        var json: Parameters

        do {
            json = try taskToJSON(task: task)
        }
        catch {
            completion(nil, error)
            return
        }

        Alamofire.request(url, method: method, parameters: json, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in

            switch response.result {
            case .success(let value):
                guard let jsonDict = value as? [String: Any],
                    let itemID = jsonDict["id"] as? Int else {
                        completion(nil, ItemError.noIdReturned)
                        return
                }

                task.id = itemID
                completion(task, nil)

            case .failure(let error):
                completion(nil, ItemError.backendError(String(data: response.data!, encoding: .utf8 )!, error))
                return
            }
        }
    }
    
    
    func saveComment(comment: Comment, completion: @escaping (Comment?, Error?) -> Void) {
        
        guard let accessToken = SessionManager.tokens?.idToken else { return }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let comment = comment
        
        var url = baseURL.appendingPathComponent("comment")
        
        var method = HTTPMethod.post
        
        if let id = comment.id {
            url = url.appendingPathComponent(String(describing: id))
            method = .put
        }
        
        var json: Parameters
        
        do {
            json = try commentToJSON(comment: comment)
            print(json)
        }
        catch {
            completion(nil, error)
            return
        }
        
        Alamofire.request(url, method: method, parameters: json, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in

            switch response.result {
            case .success(let value):
                guard let jsonDict = value as? [String: Any],
                    let itemID = jsonDict["id"] as? [Int] else {
                        completion(nil, ItemError.noIdReturned)
                        return
                }

                comment.id = itemID.first
                completion(comment, nil)

            case .failure(let error):
                completion(nil, ItemError.backendError(String(data: response.data!, encoding: .utf8 )!, error))
                return
            }
        }
    }
    
    
    // MARK: - Deleting DELETE
    
    func deleteItem(id: Int, completion: @escaping (Error?) -> Void) {
        guard let accessToken = SessionManager.tokens?.idToken else { return }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = baseURL.appendingPathComponent("item").appendingPathComponent(String(describing: id))
        
        Alamofire.request(url, method: .delete, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(nil)
                return
            case .failure(let error):
                completion(ItemError.backendError(String(data: response.data!, encoding: .utf8 )!, error))
                return
            }
        }
    }
    
    func deleteTask(id: Int, completion: @escaping (Error?) -> Void) {
        guard let accessToken = SessionManager.tokens?.idToken else { return }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = baseURL.appendingPathComponent("task").appendingPathComponent(String(describing: id))
        
        Alamofire.request(url, method: .delete, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(nil)
                return
            case .failure(let error):
                completion(ItemError.backendError(String(data: response.data!, encoding: .utf8 )!, error))
                return
            }
        }
    }
    
    
    // MARK: - Helpers
    
    func checkout(items: [Item], withTotal total: Double, completion: @escaping (Bool) -> Void) {
        
        let purchasedItems = items.map { (item) -> Item in
            item.purchased = true
            item.price = total
            return item
        }
        
        let group = DispatchGroup()
        
        for i in purchasedItems {
            group.enter()
            self.saveItem(item: i) { (_, error) in
                if let _ = error {
                    completion(false)
                    group.leave()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("Done")
            completion(true)
        }
    }
    
    
    func itemToJSON(item: Item) throws -> Parameters {
        let jsonData = try! JSONEncoder().encode(item)
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    }
    
    func taskToJSON(task: Task) throws -> Parameters {
        let jsonData = try! JSONEncoder().encode(task)
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    }
    
    func commentToJSON(comment: Comment) throws -> Parameters {
        let jsonData = try! JSONEncoder().encode(comment)
        return try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: Any]
    }
}
