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
    
    func listenObservable() {
    
        let refreshStream = buttonRefresh.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance)
            .startWith(())
        
        let requestStream = refreshStream.map { _ in return "https://api.github.com/users?access_token=f8bb670efae1d0ae8eaa80c3ad93d5a3e5ba66c0&since=" + String(arc4random() % 1000) }
        
        let responseStream = requestStream.flatMap { url in
            return Observable<[User]>.create { observer in
                let request = Alamofire.request(url).responseData(completionHandler: { (response) in
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
            let userStream: Observable<User?> = Observable.combineLatest(responseStream, clickStream)
                .map { (users, _) in
                    guard users.count > 0 else { return nil }
                    return users[Int(arc4random()) % users.count]
            }
            let suggestionStream = Observable.of(nilRefreshStream, userStream).merge()
            suggestionStream.subscribe(onNext: { (user) in
                guard let user = user else { return label.text = "LOADING.." }
                label.text = user.name
            }).addDisposableTo(disposeBag)
        }
    }
}
