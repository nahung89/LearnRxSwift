//
//  TwitterController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/21/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

struct User {
    let id: Int
    let name: String
    let avatarUrl: String
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["login"].stringValue
        avatarUrl = json["avatar_url"].stringValue
    }
}

class TwitterController : UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var buttonRefresh: UIButton!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var labelC: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenObservable()
    }
    
    // https://kipalog.com/posts/Reactive-Programming-voi-RxSwift
    func listenObservable() {
    
        let refreshStream = buttonRefresh.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance)
            .startWith(())
        
        let requestStream = refreshStream.map { _ in return "https://api.github.com/users?access_token=f8bb670efae1d0ae8eaa80c3ad93d5a3e5ba66c0&since=" + String(arc4random() % 1000) }
        
        let responseStream = requestStream.flatMap { url in
            return Observable<[User]>.create { observer in
                let request = Alamofire.request(url).validate().responseData(completionHandler: { (response) in
                    switch response.result {
                    case let .success(data):
                        let jsons = JSON.init(data: data)
                        let users = jsons.arrayValue.map({ User(json: $0) })
                        observer.onNext(users)
                        break
                    case let .failure(error):
                        observer.onError(error)
                    }
                    observer.onCompleted()
                })
                return Disposables.create {
                    request.cancel()
                }
            }
        }
        
        let nilRefreshStream: Observable<User?> = refreshStream.map { return nil }
        
        for (label, button) in [labelA: buttonA, labelB: buttonB, labelC: buttonC] as! [UILabel: UIButton] {
            let clickStream = button.rx.tap.asObservable().startWith(())
            let userStream: Observable<User?> = Observable.combineLatest(responseStream, clickStream, resultSelector: { (users, _) in
                guard users.count > 0 else { return nil }
                return users[Int(arc4random()) % users.count]
            })
            
            let suggestionStream = Observable.of(nilRefreshStream, userStream).merge()
            
            suggestionStream.subscribe({ (event) in
                switch event {
                case let .next(user):
                    guard let user = user else { return label.text = "LOADING.." }
                    label.text = user.name
                case let .error(error):
                    print("error: \(error)")
                case .completed:
                    print("finish?!")
                    break
                    
                }
            }).addDisposableTo(disposeBag)
        }
        
        // RefreshTap        -s--------------------o-------------------------------o--------------------------|--->
        // Request           -r--------------------r-------------------------------r--------------------------!--->
        // (1)Response       ------[u]------------------[u]-----------------------------[u]-------------------|--->
        // (2)ButtonATap     -s----------a-------------------------a----------------------------a-------------|--->
        // Combine(1,2)=U    -N-----Ur---Ur--------------Ur--------Ur--------------------Ur-----Ur------------|--->
        // (3)NilRefesh      -N--------------------N-------------------------------N--------------------------|--->
        // Merge(U,3)=L1     -L-----Ur---Ur--------L-----Ur--------Ur--------------L-----Ur-----Ur------------|--->
        
    }
}
