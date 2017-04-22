//
//  RotatePanController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/21/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class RotatePanController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testGestures()
    }
    
    func testGestures() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.delegate = self
        
        let rotateGesture = UIPanGestureRecognizer()
        rotateGesture.delegate = self
        view.gestureRecognizers = [panGesture, rotateGesture]
        
        let panStartObservable = panGesture.rx.event.map { $0.state == UIGestureRecognizerState.began }.filter{ $0 }
        let panEndObservable = panGesture.rx.event.map { $0.state == UIGestureRecognizerState.ended }.filter{ $0 }
        
        let rotateStartObservable = rotateGesture.rx.event.map { $0.state == UIGestureRecognizerState.began }.filter { $0 }
        let rotateEndObservable = rotateGesture.rx.event.map { $0.state == UIGestureRecognizerState.ended }.filter { $0 }
        
        let bothGesturesStarted = Observable.zip([panStartObservable, rotateStartObservable])
        let bothGesturesEnded = Observable.merge([panEndObservable, rotateEndObservable])
        
        
        bothGesturesStarted.subscribe(onNext: { [unowned self] _ in
            Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .take(5)
                .takeUntil(bothGesturesEnded)
                .subscribe(onNext: { count in
                    print("tick: \(count)")
                }, onCompleted: {
                    print("completed")
                }).addDisposableTo(self.disposeBag)
            
        }).addDisposableTo(disposeBag)
        
    }
}

extension RotatePanController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
