//
//  CircleViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 5/28/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CircleViewController: UIViewController {
    
    var circleView: UIView!
    var viewModel = CircleViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // https://www.thedroidsonroids.com/blog/ios/rxswift-by-examples-2-observable-and-the-bind/
    func setupView() {
        circleView = UIView(frame: CGRect(origin: view.center, size: CGSize(width: 100, height: 100)))
        circleView.layer.cornerRadius = 100 / 2
        circleView.center = view.center
        circleView.backgroundColor = UIColor.green
        view.addSubview(circleView)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        circleView.addGestureRecognizer(gesture)
        
        gesture.rx.event.map({ [unowned self] in $0.location(in: self.view) }).bind(to: viewModel.centerVariable).addDisposableTo(disposeBag)
        
        viewModel.colorObservable.subscribe(onNext: { [unowned self] (color) in
            self.circleView.backgroundColor = color
        }).addDisposableTo(disposeBag)
    }
    
    func panning(_ gesture: UIPanGestureRecognizer!) {
        circleView.center = gesture.location(in: view)
    }
}

class CircleViewModel {
    
    let centerVariable = Variable<CGPoint>(CGPoint.zero)
    let colorObservable: Observable<UIColor>!
    
    init() {
        colorObservable = centerVariable.asObservable()
            .map { center in
                let red: CGFloat = (center.x + center.y).truncatingRemainder(dividingBy: 255) / 255.0
                let green: CGFloat = center.y.truncatingRemainder(dividingBy: 255) / 255.0
                let blue: CGFloat = center.x.truncatingRemainder(dividingBy: 255) / 255.0
                return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
