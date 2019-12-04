//
//  PostsViewController.swift
//  blog-project-ios
//
//  Created by Salim SAÏD on 30/08/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit

struct Post: Decodable {
    let id: Int
    let title, body: String
}

class PostsViewController: UITableViewController {
    
    fileprivate func fetchPosts() {
        Service.shared.fetchPosts { (result) in
            switch result {
            case .failure(let err):
                print("Failed to fetch posts :", err)
            case .success(let posts):
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    var posts = [Post]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        cell.backgroundColor = .cyan
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.leftBarButtonItem = .init(title: "Login", style: .plain, target: self, action: #selector(handleLogin))
        navigationItem.rightBarButtonItem = .init(title: "New post", style: .plain, target: self, action: #selector(handleNewPost))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { (err) in
                if let err = err {
                    print("Failed to delete post :", err)
                    return
                }
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                print("Delete post")
            }
        }
    }
    
    @objc fileprivate func handleNewPost() {
        print("Creating new post")
        Service.shared.newPost(title: "", body: "") { (err) in
            if let err = err {
                print("Failed to create new post:", err)
                return
            }
            print("Finished creating post.")
            self.fetchPosts()
        }
    }
    
    @objc fileprivate func handleLogin() {
        guard let url = URL(string: "http://localhost:1338/api/v1/entrance/login") else { return }
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "PUT"
        
        do {
            let params = ["emailAddress": "vince@gmail.com", "password": "Dra-2633vin"]
            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.dataTask(with: loginRequest) { (data, response, error) in
                if let error = error {
                    print("Failed to login: ", error)
                }
                
                print("Probably logged in successfully..")
                self.fetchPosts()
            }.resume()
        } catch {
            print("Failed to serialize data: ", error)
        }
        
        print("Login into account.")
    }
}

