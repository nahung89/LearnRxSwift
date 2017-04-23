//
//  LearnExample.swift
//  LearnRxSwift
//
//  Created by NAH on 4/22/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ExampleController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        bindUI()
//        learnVariable()
//        learnDispose()
        testCatchError()
    }
    
    func bindUI() {
        // textField.rx.text.asObservable().bind(to: label.rx.text).addDisposableTo(disposeBag)
    }
    
    func learnVariable() {
        let a = Variable(1)
        let b = Variable(2)
        
        let c = Observable.combineLatest(a.asObservable(), b.asObservable()) { (v1, v2) in
            return v1 + v2
            }
            .map { "\($0) is " + ($0 > 0 ? "positive" : "negative") }
        
        let o = c.subscribe(onNext: { (value) in
            print("r: " + value)
        })
        
        a.value = -10
        
        o.dispose()
    }
    
    func learnDispose() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let stream = Observable<Int>.interval(0.3, scheduler: scheduler).debug("1111", trimOutput: true)
        
        let shareStrem = stream.replay(10).refCount() // == shareReplay(10)
        
        let o1 = shareStrem.subscribe { (event) in
            print("1: \(event)")
        }
        
        Thread.sleep(forTimeInterval: 3)
        
        let o2 = shareStrem.subscribe { (event) in
            print("2: \(event)")
        }
        
        
        Thread.sleep(forTimeInterval: 2)
        o1.dispose()
        
        Thread.sleep(forTimeInterval: 2)
        o2.dispose()
    }
    
    func testCatchError() {
        
        let observable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(10)
            observer.onError(RxError.timeout)
            observer.onNext(100)
            observer.onCompleted()
            return Disposables.create {
                print("disposed")
            }
        }
        
        observable.catchErrorJustReturn(1000).retry(2)
        .subscribe { (event) in
            print("e: \(event)")
        }.addDisposableTo(disposeBag)
    }
    
}
