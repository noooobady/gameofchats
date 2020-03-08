//
//  User.swift
//  gameofchats
//
//  Created by No Body on 2020/1/6.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit

class User: NSObject {//User的数据结构，传数据用
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"]as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
    
}
