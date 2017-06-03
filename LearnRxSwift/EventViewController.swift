//
//  DoEventViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 5/13/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class EventViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testDisposeWhileAction()
        print("\n\n")
        
        testDoActions()
        print("\n\n")
        
        testCatchError()
        print("\n\n")
        
//        testDispose()
//        print("\n\n")
        
    }
    
    func testDisposeWhileAction() {
        let stream = Observable<[String]>.create { (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/ReactiveX/RxSwift")!) { data, _, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        observer.onError(RxError.unknown)
                        return
                }
                observer.onNext(result.map { $0.key })
            }
            task.resume()
            
            return Disposables.create{
                log.severe("disposed!")
            }
        }
        
        // Which one come first???
        
        // 1.
        let o = stream.observeOn(Schedulers.background)
        .subscribe { (event) in
            log.info(event)
        }
        
        // 2.
        Thread.sleep(forTimeInterval: 0.2)
        o.dispose()
    }
    
    func testDoActions() {
        Observable.of(10, 20)
            .do(onNext: { (a) in
                log.info("do.onNext")
            }, onError: { (error) in
                log.debug("do.onError")
            }, onCompleted: {
                log.debug("do.onCompleted")
            }, onSubscribe: {
                log.debug("do.onSubcribe")
            }, onSubscribed: {
                log.debug("do.onSubscribed")
            }, onDispose: {
                log.debug("do.onDisposed")
            })
            .subscribe { (event) in
                log.info("event: \(event)")
            }.addDisposableTo(disposeBag)
    }
    
    func testDispose() {
        let stream = Observable<Int>.interval(1.0, scheduler: Schedulers.serial)
        
        let s1 = stream.subscribe(onNext: { (event) in
            log.info("s1: \(event)")
        }, onError: { (error) in
            log.error("s1: \(error)")
        }, onCompleted: {
            log.severe("s1-completed")
        }) {
            log.severe("s1-disposed")
        }
        s1.addDisposableTo(disposeBag)
        
        Thread.sleep(forTimeInterval: 2)
        let s2 = stream.subscribe { (event) in
            log.info("s2: \(event)")
        }
        
        Thread.sleep(forTimeInterval: 2)
        let s3 = stream.subscribe { (event) in
            log.info("s3: \(event)")
        }
        
        Thread.sleep(forTimeInterval: 2)
        s2.dispose()
        
        Thread.sleep(forTimeInterval: 2)
        s3.dispose()
    }
    
    func testCatchError() {
        func createStream(_ array: [Int?]) -> Observable<Int> {
            return Observable<Int>.create { (observer) -> Disposable in
                for i in array {
                    i != nil ? observer.onNext(i!) : observer.onError(RxError.noElements)
                }
                observer.onCompleted()
                return Disposables.create {
                    log.info("disposed")
                }
            }
        }
        
        createStream([1, 2, 3, 4, nil, 6, 7])
            .catchErrorJustReturn(-1)
            .subscribe { (event) in
                log.info("\(event)")
            }.addDisposableTo(disposeBag)
    }
    
}
