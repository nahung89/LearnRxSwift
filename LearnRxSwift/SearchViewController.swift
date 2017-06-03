//
//  ViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/20/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class SearchViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    var shownCities: [String] = []
    let allCities = ["New York", "London","London1","London2","London3", "Oslo", "Warsaw", "Berlin", "Praga"]
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        searchBar.rx.text
        .orEmpty
        .throttle(0.5, scheduler: MainScheduler.instance)
        .distinctUntilChanged()
        .subscribe(onNext: { [unowned self] (value) in
            self.shownCities = self.allCities.filter({ $0.hasPrefix(value) })
            self.tableView.reloadData()
        })
        .addDisposableTo(disposeBag)
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = shownCities[indexPath.row]
        return cell
    }
}


