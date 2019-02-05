//
//  PostListViewController.swift
//  POST
//
//  Created by micasasucasa on 2/5/19.
//  Copyright © 2019 Jacob Rosevear. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    let postController = PostController()
    
    var refreshControl = UIRefreshControl()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts {
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
        


        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTextField) in
          
        }
        
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTextField) in
            
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
            guard let username = usernameTextField.text, !username.isEmpty,
                let text = messageTextField.text, !text.isEmpty else {
                    return
            }
            self.postController.addNewPostWith(username: username, text: text, completion: {
                self.reloadTableView()
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAction)
        newPostAlertController.addAction(cancelAction)
        
        self.present(newPostAlertController, animated: true, completion: nil)
    }
    
    // Missing info error alert
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Missing info", message: "You must fill both fields out", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    func reloadTableView() {
        DispatchQueue.main.async {
            // Add networkActivityIndiator to the reloadView function
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
    

    cell.textLabel?.text = post.text
    cell.detailTextLabel?.text = "\(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
    return cell
    }
    
    
}

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
    }
}
