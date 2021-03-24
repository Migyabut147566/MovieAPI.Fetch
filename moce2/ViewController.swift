//
//  ViewController.swift
//  moce2
//
//  Created by Jose Miguel Agustin Yabut on 3/23/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
    
    struct APIresponse: Codable {
        let Search: [Search]
    }
    struct Search: Codable {
        let Title: String
        let Poster: String
    }
    
    private var collectionView: UICollectionView?
    
    var Search: [Search] = []
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/3, height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.dataSource = self
        searchBar.delegate = self
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        if let text = self.searchBar.text {
            self.Search = []
            collectionView?.reloadData()
            fetchPhotos(query: text)
        }
    }
    func fetchPhotos(query: String) {
        let urlString = "https://www.omdbapi.com/?s=(\(query))&page=2&apikey=e55825d3" //Swap test to \(query) later
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(APIresponse.self, from: data)
                DispatchQueue.main.async {
                self?.Search = jsonResult.Search
                self?.collectionView?.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Search.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imgURLString = self.Search[indexPath.row].Poster
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imgURLString)
        return cell
    }
}

