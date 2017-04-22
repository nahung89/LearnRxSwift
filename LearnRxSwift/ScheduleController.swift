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

class ScheduleController: UIViewController {

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //testSchedule()
        multiThreads()
    }
    
    // http://stackoverflow.com/questions/37973445/does-the-order-of-subscribeon-and-observeon-matter
    func testSchedule() {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            // Create at MAIN, since subscribeOn start the `observable` at MAIN
            print("[Create: \(Thread.current)]")
            observer.onNext(1)
            observer.onCompleted()
            return Disposables.create()
        }
        
        observable
            // Tell the `observable` to start at MAIN
            .subscribeOn(Schedulers.main)
            // Tell the stream to move to BACKGROUND
            .observeOn(Schedulers.background)
            // From now, stream moved to BACKGROUND
            .map({ (item) in return "[Map1: \(Thread.current)]" })
            // Tell the stream to move to MAIN
            .observeOn(Schedulers.main)
            // From now, stream moved to MAIN
            .map({ (item) in return "\(item) [Map2: \(Thread.current)]" })
            // Tell the stream to move to BACKGROUND
            .observeOn(Schedulers.background)
            // From now, stream move to BACKGROUND
            .subscribe(onNext: { (value) in
                  print("[Subcribe: \(Thread.current)] - \(value)")
            })
            .addDisposableTo(disposeBag)
    }

    // https://chucuoi.net/2016/10/30/reactive-programming-trong-swift-phan-3/
    // 2. Xử lý song song trong Rx
    func multiThreads() {
        let stream = Observable.of(1, 2, 3, 4, 5)
            .flatMap { i in
                Observable.just(i)
                    .subscribeOn(Schedulers.background)
                    .map { self.intenseCalculation($0) }
        }
        
        stream
            .subscribe(onNext: { i in
                print(i)
            })
            .addDisposableTo(disposeBag)
    }
    
    func intenseCalculation(_ i: Int) -> Int {
        Thread.sleep(forTimeInterval: TimeInterval(5))
        return i
    }
}
