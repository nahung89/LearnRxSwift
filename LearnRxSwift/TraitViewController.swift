//
//  TrailController.swift
//  LearnRxSwift
//
//  Created by NAH on 4/23/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class TraitViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testSingle()
        print("\n\n")
        
        testMaybe()
        print("\n\n")
        
        testComplete()
        print("\n\n")
    }
    
    func testSingle() {
        for str in ["https://api.github.com/repos/ReactiveX/RxSwift", "https://abc.com"] {
            getRepo(str)
                .observeOn(Schedulers.main)
                .subscribe(onSuccess: { (element) in
                    log.info(element.count)
                }, onError: { (error) in
                    log.error(error.localizedDescription)
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func testComplete() {
        for str in ["a string", nil] {
            saveDisk(str)
                .subscribe(onCompleted: {
                    log.info("Save success!")
                }, onError: { (error) in
                    log.error(error.localizedDescription)
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func testMaybe() {
        for i in -2...2 {
            generateString(i)
                .subscribe(onSuccess: { (element) in
                    log.info(element)
                }, onError: { (error) in
                    log.error(error.localizedDescription)
                }, onCompleted: {
                    log.info("Completed")
                })
                .addDisposableTo(disposeBag)
        }
    }
}

// MARK: - Creation
extension TraitViewController {
    
    // MARK: Single: element | error
    func getRepo(_ repo: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: repo)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        single(.error(RxError.unknown))
                        return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    // MARK: Completable: complete | error
    func saveDisk(_ string: String?) -> Completable {
        return Completable.create { completable in
            if let string = string, !string.isEmpty {
                completable(.completed)
            } else {
                completable(.error(RxError.noElements))
            }
            return Disposables.create()
        }
    }
    
    // MARK: Mayble: success | complete | error
    func generateString(_ from : Int) -> Maybe<String> {
        return Maybe<String>.create { maybe in
            if from > 0 {
                maybe(.success("random-generater-\(from)"))
            }
            else if from == 0 {
                maybe(.completed)
            }
            else {
                maybe(.error(RxError.unknown))
            }
            return Disposables.create()
        }
    }
}
