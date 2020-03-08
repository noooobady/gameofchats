//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by No Body on 2020/1/16.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {//不同于UItableViewCell,UICollectionViewCell中没有默认的textView
        let tv = UITextView()
        tv.text = "sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false//没有这句后面无法初始化
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false//使图片上不能打字
        return tv
    }()
    
    static let blueColor = UIColor(r: 0 ,g: 137 ,b: 249)
    
    let bubbleView: UIView = {//聊天气泡
      let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16//边角变圆
        view.layer.masksToBounds = true //=true ,cornerRadius才有效
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"test")//删掉也行
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        //make sure that the aspect ratio for the image is actually kept or maintained whatever we render
        //the image
        return imageView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        //make sure that the aspect ratio for the image is actually kept or maintained whatever we render
        //the image
        imageView.backgroundColor = UIColor.brown
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?//让宽度成为变量，随处更改，以最后一个为准,//最后一个是在chatlogcontroller/collectionView
    var bubbleViewRightAnchor:NSLayoutConstraint?//让右锚点成为变量，随处更改，以最后一个为准
    var bubbleViewLeftAnchor:NSLayoutConstraint?
    
    override init(frame: CGRect) {//聊天室每一行的结构
        super.init(frame: frame)
        //backgroundColor = UIColor.red
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive=true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive=true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive=true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive=true
        
        //x,y,w,h
        //.isActive=true//-8气泡向右推
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 8)
        bubbleViewLeftAnchor?.isActive = false//在chatlogcontroller里根据条件改为true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive=true
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive=true
        bubbleView.widthAnchor.constraint(equalToConstant: 200).isActive=true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive=true
        //x,y,w,h
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive=true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive=true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive=true
        
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive=true
        
        textView.widthAnchor.constraint(equalToConstant: 200).isActive=true
        
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive=true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
