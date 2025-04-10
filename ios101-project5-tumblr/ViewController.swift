//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke




class ViewController: UIViewController, UITableViewDataSource {
    
    
    
    
    private var blog: Blog?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return blog?.response.posts.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Attempting to dequeue cell for row \(indexPath.row)")
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TumblrCell", for: indexPath) as? TumblrCell else {
                print("❌ Failed to dequeue TumblrCell")
                return UITableViewCell()
            }
            
            print("✅ Successfully dequeued cell")
            
            guard let blog = self.blog, indexPath.row < blog.response.posts.count else {
                print("❌ Blog data not available for row \(indexPath.row)")
                return cell
            }
        
        let tumblrPost = blog.response.posts[indexPath.row]

        cell.postImageView.contentMode = .scaleAspectFill
        cell.postImageView.clipsToBounds = true

        cell.descriptionLabel.text = tumblrPost.caption
        cell.descriptionLabel.numberOfLines = 3 // Limit to 3 lines


        let url = tumblrPost.photos[0].originalSize.url
        Nuke.loadImage(with: url, into: cell.postImageView)



        return cell
    }
    

 
    @IBOutlet weak var tableViewTumblr: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewTumblr.dataSource = self
        fetchPosts()
        tableViewTumblr.rowHeight = UITableView.automaticDimension
        tableViewTumblr.estimatedRowHeight = 250
    }

 

    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    
                    self?.blog = blog
                    
                                    self?.tableViewTumblr.reloadData()
                                    
                                    // Add this to debug
                                    print("✅ Data loaded: \(blog.response.posts.count) posts")
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
