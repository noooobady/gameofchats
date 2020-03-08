//
//  Message.swift
//  gameofchats
//
//  Created by No Body on 2020/1/12.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {//Message的数据结构，传数据用
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl:String?
    var imageWidth:NSNumber?//必须是NSNumber才能用.floatValue转换成float
    var imageHigh:NSNumber?
    
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWith"]as? NSNumber
        self.imageHigh = dictionary["imageHigh"]as? NSNumber
    }
    
    
    func chatPartnerId() ->String{//返回对方ID//从UserCell移入这里，让所有的title都显示对
        
        if fromId == Auth.auth().currentUser?.uid{//信息为当前用户发出去的
            return toId!//返回接受者ID
        }else {//当前用户未接受者
            return fromId!//返回发送者iD
        }
    }

}
// let values = ["toId": toId,"fromId":fromId as Any,"timestamp":timestamp,"imageUrl": imageUrl,"imageWith": image.size.width,"imageHight": image.size.height]
