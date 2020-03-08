//
//  UserCell.swift
//  gameofchats
//
//  Created by No Body on 2020/1/13.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit//将usercell从NewMessageController移到这.让所有的tableview都能用
import Firebase
class UserCell: UITableViewCell {//TableViewCell用户栏，文字、图片显示尺寸设置
    
    var message: Message?{
        didSet{
           
                   setupNameAndProfileImage()
               
                   detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue{//用if使程序更安全
                let timestampDate = NSDate(timeIntervalSince1970: seconds)//秒化成日期
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"//时间格式为小时：分钟：秒，略掉了年月日
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
                   //timeLable.text = message?.timestamp?.stringValue
        }
    }


    private func setupNameAndProfileImage(){
        
//        let chatPartnerId: String?//移入Model.Message
//        if message?.fromId == Auth.auth().currentUser?.uid{//解决信息只显示接受者名字bug
//            chatPartnerId = message?.toId
//        }else{
//            chatPartnerId = message?.fromId
//        }
        
        if let id = message?.chatPartnerId(){//获取名字
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.textLabel?.text = dictionary["name"] as?String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"]{
                     self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl as! String)
                    }
                }
                //print(snapshot)
            }, withCancel: nil)
        }
    }
    
    
override func layoutSubviews() {
    super.layoutSubviews()
    textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
    detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
}

let profileImageView: UIImageView = {
       let imageView = UIImageView()
    //imageView.image = UIImage(named: "test")
    imageView.translatesAutoresizingMaskIntoConstraints = false//显示
    imageView.layer.cornerRadius = 18//变圆，角半径18
    imageView.layer.masksToBounds = true//显示变圆
    imageView.contentMode = .scaleAspectFill//原图比例显示//消除瑕疵
    //cell.imageView?.contentMode = .scaleAspectFill//原图比例显示
       return imageView
   }()
    
let timeLabel: UILabel = {
    let label = UILabel()
    //lable.text = "HH:MM:SS"
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor.darkGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
   }()


override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    addSubview(profileImageView)
    addSubview(timeLabel)
    //iod9 constaraint anchors
    //need x,y,width,height anchors
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    //need x,y,width,height anchors
    timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 18).isActive = true
    timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    
    
   }

required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
   }

}
