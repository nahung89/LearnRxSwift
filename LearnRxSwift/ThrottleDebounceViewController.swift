//
//  ThrottleDebounceViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 6/3/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ThrottleDebounceViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        log.info("Start Debounce!")
        testWithDebounce().subscribe({ (event) in
            log.info("D: \(event)")
        }).addDisposableTo(disposeBag)
        log.info("Finish Debounce!")
        
        
        Thread.sleep(until: Date().addingTimeInterval(5))
        print("\n\n\n")
        
        log.info("Start Thrrotle!")
        testWithThrottle().subscribe({ (event) in
            log.info("T: \(event)")
        }).addDisposableTo(disposeBag)
        log.info("Finish Thrrotle!")
        
    }
    
    
    func testWithThrottle() -> Observable<Int> {
        return
            Observable.of(7,8) // 1
                .concat(Observable.never()) // 2
                .throttle(3.0, scheduler: Schedulers.background) // 3
                .take(2) // 4
        
        // 1. -7-8-|->
        // 2. -7-8------------------------------>
        // 3. -7---------------8---------------->
        // 4. -7---------------8-|-------------->
    }
    
    func testWithDebounce() -> Observable<String> {
        return
            Observable.of("A", "B") // 1
                .concat(Observable.never()) // 2
                .debounce(3.0, scheduler: Schedulers.background) // 3
                .take(1) // 4
        
        // 1. -A-B-|---------------------------->
        // 2. -A-B------------------------------>
        // 3. -----------------B---------------->
        // 4. -----------------B-|-------------->
    }
    
}
