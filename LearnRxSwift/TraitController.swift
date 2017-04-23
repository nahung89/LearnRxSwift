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

class TrailController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // testSingle()
        // testMaybe()
        testComplete()
    }
    
    func testSingle() {
        //
        getRepo("ReactiveX/RxSwift")
        .subscribe(onSuccess: { (element) in
            print("Success: ", element)
        }, onError: { (error) in
            print("Error: ", error)
        })
        .addDisposableTo(disposeBag)
    }
    
    func testComplete() {
        for str in ["A String", nil] {
            saveDisk(string: str)
                .subscribe(onCompleted: {
                    print("Save success!")
                }, onError: { (error) in
                    print("Save fail: ", error)
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func testMaybe() {
        for i in -1...1 {
            generateString(i)
            .subscribe(onSuccess: { (element) in
                print("Success: ", element)
            }, onError: { (error) in
                print("Error: ", error)
            }, onCompleted: { 
                print("Completed")
            })
            .addDisposableTo(disposeBag)
        }
    }
    
    // Single: element | error
    func getRepo(_ repo: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!) { data, _, error in
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
    
    func saveDisk(string: String?) -> Completable {
        return Completable.create { completable in
            let disposable = Disposables.create()
            guard let string = string, !string.isEmpty else {
                completable(.error(RxError.noElements))
                return disposable
            }
            completable(.completed)
            return disposable
        }
    }
    
    func generateString(_ from : Int) -> Maybe<String> {
        return Maybe<String>.create { maybe in
            if from > 0 {
                maybe(.success("RxSwift"))
            }
            else if from == 0 {
                maybe(.completed)
            }
            else {
                maybe(.error(RxError.unknown))
            }
            return Disposables.create {}
        }
    }
}
