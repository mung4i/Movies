//
//  ViewController.swift
//  Movies
//
//  Created by Martin Mungai on 30/10/2018.
//  Copyright © 2018 Martin Mungai. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.search.delegate = self
    }
    
    func refreshTableView() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func clearTableView() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func fetchMovies(keyword: String) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        service.sendRequest(search: ["s": keyword], queue: queue) { [weak self] (result) in
            switch result {
            case .success(let response):
                self?.movies = response as? MovieResponse
                self?.fetchImages(queue: queue, titles: (self?.movies)!)
                self?.refreshTableView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchImages(queue: DispatchQueue, titles: MovieResponse) {
        
        var count = 0
        titles.movies.forEach {
            let url = URL(string: $0.poster)
            service.getImage(from: url!, queue: queue) { [weak self] (result) in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data as! Data)
                    self?.setImage(row: count, image: image!)
                    count += 1
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func setImage(row: Int, image: UIImage) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: row, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as? MovieTableViewCell
            cell?.setImage(image: image)
//            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    let service = MoviesService()
    private var movies: MovieResponse?
    private var images: [UIImage]?
    
    
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var tableView: UITableView!
}

extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.movies.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let movies = self.movies?.movies else { return UITableViewCell() }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieTableViewCell

        cell?.logo.image = images?[indexPath.row]
        cell?.label.text = movies[indexPath.row].title
        
        return cell!
    }
}

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell
        
        if movies?.movies[indexPath.row].title == cell?.label.text {
            let id = movies?.movies[indexPath.row].id
            let year = movies?.movies[indexPath.row].year
            let type = movies?.movies[indexPath.row].type
            let alertController = UIAlertController(title: cell?.textLabel?.text,
                                                    message: "Year: \(year!) \n Type: \(type!) \n imDb ID: \(id!) ",
                                                    preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension MoviesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.clearTableView()
        self.fetchMovies(keyword: textField.text!)
        return true
    }
}


