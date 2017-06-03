//
//  FlatMapController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/22/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FlatMapViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch1()
        fetch2()
    }
    
    func fetch1() {
        let stream = schools().flatMap { (schools) in
            return Observable.from(schools)
            }
            .flatMap { (school) in
                return self.students(school)
            }
            .flatMap { (students) in
                return Observable.from(students)
            }
            .flatMap { (student) in
                return self.scores(student)
            }
            .flatMap { (scores) in
                return Observable.from(scores)
        }
        
        stream.subscribe(onNext: { (score) in
            print(score)
        }, onCompleted: {
            log.info("complete-1")
        })
            .addDisposableTo(disposeBag)
    }
    
    func fetch2() {
        let stream = schools()
            .map({ (schools) in
                return Observable.from(schools)
            })
            .concat()
            .map({ (school) in
                return self.students(school)
            })
            .concat()
            .map({ (students) in
                return Observable.from(students)
            })
            .concat()
            .map({ (student) in
                return self.scores(student)
            })
            .concat()
            .flatMap({ (scores) in
                return Observable.from(scores)
            })
        
        stream.subscribe(onNext: { (score) in
            print(score)
        }, onCompleted: {
            log.info("complete-2")
        })
            .addDisposableTo(disposeBag)
    }
    
    func schools() -> Observable<[String]> {
        return Observable<[String]>.just(createEntity("🏠"))
    }
    
    func students(_ school: String) -> Observable<[String]> {
        return Observable<[String]>.just(createEntity(school+"_🚶"))
    }
    
    func scores(_ student: String) -> Observable<[String]> {
        return Observable<[String]>.just(createEntity(student+"_⛳"))
    }
    
    func createEntity(_ name: String) -> [String] {
        return (0...5).map{ "\(name)\($0)" }
    }
}
