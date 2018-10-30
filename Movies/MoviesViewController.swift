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
        
        self.addProps(button: _next)
        self.addProps(button: _previous)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.search.delegate = self
    }
    
    func refreshTableView() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func clearTableView() {
        self.images = []
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func fetchMovies(keyword: String, page: Int) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        service.sendRequest(search: ["s": keyword, "page": "\(page)"], queue: queue) { [weak self] (result) in
            DispatchQueue.main.async { self?.createSpinnerView() }
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
                    self?.images.append(image!)
                    count += 1
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func addProps(button: UIButton) {
        button.layer.cornerRadius = 5
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func setImage(row: Int, image: UIImage) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: row, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as? MovieTableViewCell
            cell?.setImage(image: image)
        }
    }
    
    let service = MoviesService()
    private let activityIndicator = UIActivity.init()
    private var movies: MovieResponse?
    private var images = [UIImage]()
    private var page = 1
    
    @IBAction func nextTapped(_ sender: UIButton) {
        page += 1
        fetchMovies(keyword: self.search.text!, page: page)
    }
    
    @IBAction func previousTapped(_ sender: UIButton) {
        page -= 1
        fetchMovies(keyword: self.search.text!, page: page)
    }
    
    @IBOutlet weak var _next: UIButton!
    @IBOutlet weak var _previous: UIButton!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var tableView: UITableView!
}

extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.movies.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        createSpinnerView()
        guard let movies = self.movies?.movies else { return UITableViewCell() }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieTableViewCell
        
        guard let defaultImage = UIImage(named: "poster-placeholder") else { return UITableViewCell() }
        
        cell?.label.text = movies[indexPath.row].title
        
        if images.count != movies.count {
            cell?.logo.image = defaultImage
            return cell!
        }
        
        cell?.logo.image = images[indexPath.row]

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
        self.fetchMovies(keyword: textField.text!, page: 1)
        return true
    }
}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


