//
//  PostController.swift
//  POST
//
//  Created by micasasucasa on 2/4/19.
//  Copyright © 2019 Jacob Rosevear. All rights reserved.
//

import Foundation
class PostController {
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void){
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        guard let unwrappedURL = baseURL else { completion(); return }
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        
        
        let getterEndpoint = url.appendingPathExtension("json")
        print(getterEndpoint)
    
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { ( data, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
                return
            }
        
            guard let data = data else { completion(); return}
            
            let decoder = JSONDecoder()
            
            do {
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.compactMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                print(error)
                completion()
                return
            }
        })
        dataTask.resume()
    }
    func addNewPostWith(username: String, text: String, completion: @escaping() -> Void) {
        let post = Post(username: username, text: text)
        var postData: Data
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch {
            print(error)
            completion()
            return
        }
        
        guard let unwrappedURL = baseURL else { completion(); return }
        
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: postEndpoint)
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completion()
                NSLog(error.localizedDescription)
                return
            }
            
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else {
                    NSLog("Data is nil. Unable to verify if data was able to be put to endpoint.")
                    completion()
                    return }
            
            NSLog(responseDataString)
            
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
    
}
