//
//  UIImagePickerController+Rx.swift
//  LearnRxSwift
//
//  Created by NAH on 5/13/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

//extension UIImagePickerController {
//    
//    // Factory method that enables subclasses to implement their own `delegate`.
//    func createRxDelegateProxy() -> RxImagePickerControllerDelegateProxy {
//        return RxImagePickerControllerDelegateProxy(parentObject: self)
//    }
//}

extension Reactive where Base: UIImagePickerController {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxImagePickerControllerDelegateProxy.proxyForObject(base)
    }
    
    var didFinishPickingMediaWithInfo: Observable<[String : Any]> {
        let proxy = RxImagePickerControllerDelegateProxy.proxyForObject(base)
        return proxy.didFinishPickingSubject
    }
    
    var didCancel: Observable<Void> {
        let proxy = RxImagePickerControllerDelegateProxy.proxyForObject(base)
        return proxy.didCancelPickingSubject
    }
}

class RxImagePickerControllerDelegateProxy: DelegateProxy {
    
    fileprivate var finishPickingSubject = PublishSubject<[String: Any]>()
    fileprivate var cancelPickingSubject = PublishSubject<Void>()
    
    var didFinishPickingSubject: Observable<[String: Any]> {
        return finishPickingSubject
    }
    
    var didCancelPickingSubject: Observable<Void> {
        return cancelPickingSubject
    }
    
    deinit {
        finishPickingSubject.onCompleted()
        cancelPickingSubject.onCompleted()
    }
    
//    // Go with `createRxDelegateProxy() -> RxImagePickerControllerDelegateProxy`
//    override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
//        let imagePickerController = (object as! UIImagePickerController)
//        return imagePickerController.createRxDelegateProxy()
//    }
}

extension RxImagePickerControllerDelegateProxy: DelegateProxyType {
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        return (object as? UIImagePickerController)?.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        (object as? UIImagePickerController)?.delegate = delegate as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    }
}

extension RxImagePickerControllerDelegateProxy: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        finishPickingSubject.onNext(info)
        self._forwardToDelegate?.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelPickingSubject.onNext()
        self._forwardToDelegate?.imagePickerControllerDidCancel(picker)
    }
}
