//
//  Service.swift
//  blog-project-ios
//
//  Created by Salim SAÏD on 10/09/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit

class Service: NSObject {
    static let shared = Service()
    
    let baseUrl = "http://localhost:1338"
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
        guard let url = URL(string: "\(baseUrl)/home") else {return}
        
        var fetchPostRequest = URLRequest(url: url)
        fetchPostRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        URLSession.shared.dataTask(with: fetchPostRequest) {(data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch posts.", error)
                    return
                }
                
                guard let data = data else {return}
                
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
                print(String(data: data, encoding: .utf8) ?? "")
            }
            }.resume()
    }
    
    func newPost(title: String, body: String, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseUrl)/post") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let params = ["title": title, "postBody": body]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else {return}
                print(String(data: data, encoding: .utf8) as Any)
                }.resume()
        } catch {
            completion(error)
        }
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseUrl)/post/\(id)") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                
                completion(nil)
            }
            }.resume()
    }
}
