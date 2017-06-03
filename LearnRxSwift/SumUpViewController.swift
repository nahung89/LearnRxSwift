//
//  SumUpViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 5/28/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import Alamofire

class SumUpViewController: UIViewController {
    
    @IBOutlet weak fileprivate var searchBar: UISearchBar!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    fileprivate var model: RepositoryNetworkModel!
    
    fileprivate var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    // https://www.thedroidsonroids.com/blog/ios/rxswift-examples-4-multithreading/
    func setupRx() {
        let searchObservable = searchBar.rx.text
            .orEmpty
            .filter({ !$0.isEmpty })
            .debounce(0.5, scheduler: Schedulers.main)
            .distinctUntilChanged()
        
        model = RepositoryNetworkModel(withNameObservable: searchObservable)
        let fetchs = model.fetchRepositories()
        
        fetchs.drive(tableView.rx.items(cellIdentifier: "cell")) { (index, repo, cell) in
            cell.textLabel?.text = repo.name
            }.addDisposableTo(disposeBag)
        
        fetchs.drive(onNext: { [unowned self] (repos) in
            if repos.count == 0 {
                let alert = UIAlertController(title: ":(", message: "No repositories for this user.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                if self.navigationController?.visibleViewController?.isMember(of: UIAlertController.self) != true {
                    self.present(alert, animated: true)
                }
            }
        }).addDisposableTo(disposeBag)
        
        
    }
    
}

fileprivate struct RepositoryNetworkModel {
    
    private var repositoryName: Observable<String>
    
    init(withNameObservable nameObservable: Observable<String>) {
        self.repositoryName = nameObservable
    }
    
    func fetchRepositories() -> Driver<[Repository]> {
        return repositoryName
            .subscribeOn(MainScheduler.instance)
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .flatMapLatest({ text in
                return self.requestJSON(url: "https://api.github.com/users/\(text)/repos")
            })
            .map { (json) in
                var array: [Repository] = []
                for item in json.arrayValue {
                    array.append(Repository(json: item))
                }
                return array
            }.asDriver(onErrorJustReturn: [])
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
    }
    
    fileprivate func requestJSON(url: String) -> Observable<JSON>{
        return Observable<JSON>.create({ (observer) in
            let request = Alamofire.request(url, method: .get).responseJSON(completionHandler: { (response) in
                switch response.result {
                case let .success(value):
                    observer.onNext(JSON(value))
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }
}


fileprivate struct Repository {
    let id: String
    let language: String
    let url: String
    let name: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        url = json["url"].stringValue
        language = json["language"].stringValue
        name = json["name"].stringValue
    }
    
}
