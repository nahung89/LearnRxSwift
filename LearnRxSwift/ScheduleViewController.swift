//
//  ScheduleController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/22/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ScheduleViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testSchedule()
        multiThreads()
    }
    
    // http://stackoverflow.com/questions/37973445/does-the-order-of-subscribeon-and-observeon-matter
    func testSchedule() {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            // Create at MAIN, since subscribeOn start the `observable` at `main`
            log.info("Create")
            observer.onNext(1)
            observer.onCompleted()
            return Disposables.create()
        }
        
        observable
            // Tell the `observable` to start at `main`
            .subscribeOn(Schedulers.main)
            // Tell the stream to move to `background`
            .observeOn(Schedulers.background)
            // From now, stream moved to `background`
            .map({ (item) in
                log.info("Map1")
            })
            // Tell the stream to move to `main`
            .observeOn(Schedulers.main)
            // From now, stream moved to `main`
            .map({ (item) in
                log.info("Map2")
            })
            // Tell the stream to move to `initialzie`
            .observeOn(Schedulers.initialzie)
            // From now, stream move to `initialzie`
            .subscribe(onNext: { (value) in
                log.info("Subcribe: \(value)")
            })
            .addDisposableTo(disposeBag)
    }

    // https://chucuoi.net/2016/10/30/reactive-programming-trong-swift-phan-3/
    // 2. Concurrent Operations
    func multiThreads() {
        let stream = Observable.of(1, 2, 3, 4, 5)
            .flatMap { i in
                Observable.just(i)
                    .subscribeOn(Schedulers.background)
                    .map { self.intenseCalculation($0) }
        }
        
        stream
            .observeOn(Schedulers.main)
            .subscribe(onNext: { i in
                log.info(i)
            })
            .addDisposableTo(disposeBag)
    }
    
    func intenseCalculation(_ i: Int) -> Int {
        Thread.sleep(forTimeInterval: TimeInterval(3))
        return i
    }
}
