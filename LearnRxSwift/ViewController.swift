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

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    
    var shownCities = [String]() // Data source for UITableView
    let allCities = ["New York", "London","London1","London2","London3", "Oslo", "Warsaw", "Berlin", "Praga"] // Our mocked API data source
    let all = (["", ""])
    
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
        .subscribe(onNext: { (value) in
            self.shownCities = self.allCities.filter({ $0.hasPrefix(value) })
            self.tableView.reloadData()
        })
        .addDisposableTo(disposeBag)
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = shownCities[indexPath.row]
        return cell
    }
}


