//
//  User.swift
//  LearnRxSwift
//
//  Created by NAH on 4/21/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    let id: Int
    let name: String
    let avatarUrl: String
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["login"].stringValue
        avatarUrl = json["avatar_url"].stringValue
    }
}
