//
//  Schedulers.swift
//  LearnRxSwift
//
//  Created by NAH on 4/22/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import RxSwift

class Schedulers {
    
    static var main: SchedulerType {
        return MainScheduler.instance
    }
    
    static var background: SchedulerType {
        return ConcurrentDispatchQueueScheduler.init(qos: DispatchQoS.background)
    }
    
    static var initialzie: SchedulerType {
        return ConcurrentDispatchQueueScheduler.init(qos: DispatchQoS.userInitiated)
        
    }
    
    static var serial: SchedulerType {
        return SerialDispatchQueueScheduler(qos: .default)
    }
}
