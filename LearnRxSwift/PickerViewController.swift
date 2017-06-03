//
//  PickerViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 5/13/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PickerViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var buttonImage: UIButton!
    var disposeBag = DisposeBag()
    
    deinit {
        log.severe("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStreamA()
    }
    
    // More prefer!!!
    func createStreamA() {
        buttonImage.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            self.present(self.imagePicker, animated: true)
        }).addDisposableTo(disposeBag)
        
        imagePicker.rx.didFinishPickingMediaWithInfo
            .subscribe(onNext: { [unowned self] (info) in
                log.info(info)
                self.imagePicker.dismiss(animated: true)
            })
            .addDisposableTo(disposeBag)
        
        imagePicker.rx.didCancel
            .subscribe(onNext: { [unowned self] _ in
                self.imagePicker.dismiss(animated: true)
            })
            .addDisposableTo(disposeBag)
        
        // Forward delegate to normal object.
        // -> Example: imagePicker.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        
        // *** Warning: If `retain` delegate, we will have a retain-cycle: {controller > imagePicker > delegateProxy > controller}, which will never release
        // 1. controller -> imagePicker // strong reference
        // 2. imagePicker -> delegateProxy  // via objc_setAssociatedObject(object, self.delegateAssociatedObjectTag(), proxy, .OBJC_ASSOCIATION_RETAIN)
        // 3. delegateProxy -> controller // via imagePicker.rx.delegate.setForwardToDelegate(self, retainDelegate: true)
    }
    
    func createStreamB() {
        let imagePickerStream = buttonImage.rx.tap.asObservable().flatMap({ [unowned self] _ in
            return self.showImagePicker()
        }).map ({ $0.rx }).shareReplayLatestWhileConnected()
        
        imagePickerStream.flatMap ({
            return $0.didFinishPickingMediaWithInfo
        }).subscribe(onNext: { [unowned self] (info) in
            log.info(info)
            self.dismiss(animated: true)
        }).addDisposableTo(disposeBag)
        
        imagePickerStream.flatMap ({
            return $0.didCancel
        }).subscribe(onNext: { [unowned self] _ in
            self.dismiss(animated: true)
        }).addDisposableTo(disposeBag)
    }
}

extension PickerViewController {
    
    func showImagePicker() -> Observable<UIImagePickerController> {
        return Observable<UIImagePickerController>.create { [weak self] (observer) -> Disposable in
            guard let wSelf = self, wSelf.presentedViewController == nil else {
                observer.onError(RxError.noElements)
                return Disposables.create()
            }
            let imagePicker = UIImagePickerController()
            wSelf.present(imagePicker, animated: true)
            observer.onNext(imagePicker)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
