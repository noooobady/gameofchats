//
//  ChatLogController.swift
//  gameofchats
//  屏幕旋转bug编译器自动解决
//  Created by No Body on 2020/1/11.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{//加UITextFieldDelegate为了使用回车键,加UICollectionViewDelegateFlowLayout为了func collectionView
    //加UIImagePickerControllerDelegate为了可以选择图片,加UINavigationControllerDelegate为了可以进入相册
    
    var user: User?{//在chatlogcontroller中可以显示聊天对象信息
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
     var messages = [Message]()
    
    func observeMessages(){//获取聊天信息至messages
        guard let uid = Auth.auth().currentUser?.uid ,let toId = user?.id else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in//当前用户的信息头
            //print(snapshot)
            let messageId = snapshot.key//uid/当前用户的下面就一个数据，messages中的ID，每条消息都存入到了两者ID下
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in//获取当前用户相关的全部信息，不管当前用户为接受者还是发送者
                //print(snapshot)
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
                //do we need to attempt filtering anymore?
            // print("we fetched a message from firebase,and we need to decide whether or not to filter it out:",message.text)
                self.messages.append(message)//messages数组中存入从数据库中获取的信息
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    //每次刷新聊天信息自动滚动到最下面
                })
//                if message.chatPartnerId() == self.user?.id{//只收当前聊天对象与当前用户之间的消息，16节有了toId之后这个判断语句可以去掉
//                    self.messages.append(message)
//                    DispatchQueue.main.async(execute: {
//                        self.collectionView?.reloadData()
//                    })
//                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {//接出textfile的内容，为了存进数据库，let换成lazy var为了使用回车键
           let textField = UITextField()
           textField.placeholder = "Enter message..."
           textField.translatesAutoresizingMaskIntoConstraints = false
           textField.delegate = self//为了使用回车键
           return textField
       }()
    
    let cellId = "cellId"
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //navigationItem.title = "Chat log Controller"
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //聊天室气泡顶端上下空隙设置为8
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        //滑杆上下空隙设置为0、50
        collectionView?.alwaysBounceVertical = true//可以上下拖拽，滑动聊天信息
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //引用ChatMessageCell
        
        collectionView?.keyboardDismissMode = .interactive//下拉聊天信息，键盘也被拉下来
         //setupInputComponents()
           setupKeyboardObservers()//第一种POP键盘的方法，输入栏不跟键盘，18节改为自动滑动到最下聊天信息之用
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x:0,y:0,width: view.frame.width,height: 50)//containerView在屏幕最下方
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))//点击执行函数
         uploadImageView.isUserInteractionEnabled = true//可以点击，不声明默认为false
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)//带system参数,有点击效果，加入发送键，从下面复制来的
               sendButton.setTitle("Sent", for: .normal)
               sendButton.translatesAutoresizingMaskIntoConstraints = false
               sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
               containerView.addSubview(sendButton)
               //x,y,w,h
               sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
               sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                   sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
               sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
               containerView.addSubview(inputTextField)
               //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor,constant: 8).isActive = true//向左边顶8个距离
               inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
               inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
               inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
               
               let separetorLineView = UIView()
               separetorLineView.backgroundColor = UIColor.gray
               separetorLineView.translatesAutoresizingMaskIntoConstraints = false
               containerView.addSubview(separetorLineView)
               //x,y,w,h
               separetorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
               separetorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
               separetorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
               separetorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
        
    ///////////选择图片与存储⬇️
    @objc func handleUploadTap(){
        //print("123")
        let picker = UIImagePickerController()
         picker.delegate = self
         picker.allowsEditing = true
         present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {//此方程swift自带API，可以实现进入相册选择照片
        //print("we select an image")//点击图片时打印
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)//下面的4.2方程

        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"]as?UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImge = info["UIImagePickerControllerEditedImage"]as?UIImage{
            selectedImageFromPicker = originalImge
        }
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
          dismiss(animated: true, completion: nil)//选完后结束进程
    }

   
    // Helper function inserted by Swift 4.2 migrator.//没有下面这些。info中括号后面的就需要改为.editedimage/.originalimage
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){//上传图片，获取URL，上传URL到message
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)//会自动创建两个文件夹
        if let uploadDate = image.jpegData(compressionQuality: 0.2){//压缩
            ref.putData(uploadDate, metadata: nil) { (metadata, error) in//存储
                if error != nil{
                    print("Failed to upload image:",error!)
                    return
                }
                ref.downloadURL { (url, err) in//确定downloadURL没错
                    if let err = err{
                        print(err)
                        return
                    }
                    self.sendMessageWithImageUrl(url?.absoluteString ?? "", image: image)//message中存入图片的下载链接和尺寸
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {//此方程为swift自带API
          dismiss(animated: true, completion: nil)
    }
    
    ///////////选择图片与存储⬆️
    override var inputAccessoryView: UIView?{//第二种POP键盘的方法，输入栏跟键盘
        get {
            return inputContainerView//可以将键盘的字输入到textField
        }
    }
    
    override var canBecomeFirstResponder : Bool {//没用
       return true
    }
    
     func setupKeyboardObservers() {//键盘跳起聊天列表也跳，
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)//键盘观察事件
            
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    //
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        }
        
        @objc func handleKeyboardDidShow() {
            if messages.count > 0 {//防止没有聊天信息时crash
                let indexPath = IndexPath(item: messages.count - 1, section: 0)
                collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            NotificationCenter.default.removeObserver(self)
        }
        
//        func handleKeyboardWillShow(_ notification: Notification) {
//            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//            let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
//            containerViewBottomAnchor?.constant = -keyboardFrame!.height
//            UIView.animate(withDuration: keyboardDuration!, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
//
//        func handleKeyboardWillHide(_ notification: Notification) {
//            let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
//            containerViewBottomAnchor?.constant = 0
//            UIView.animate(withDuration: keyboardDuration!, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
        
   
       
    
   
    

    ////////////聊天气泡设置⬇️
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {//应用cell设置气泡,可以在这里面修改气泡cell的内容，chatMessageCell像一个基础，在这里也能改
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text//设置气泡文字内容
        
       setupCell(cell: cell, message: message)
        
        //lets modify the bubbleView's width somehow???
        if let text = message.text {//还有图片，区分开
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
                   //聊天气泡和text大小相匹配，+32为了有一定的空隙
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            
        }
       //lode image
       
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell,message:Message){
        //应用chatmessagecell,根据条件修改，在collectionView里执行
        if let profileImageUrl = self.user?.profileImageUrl{//user是聊天对象，开头就有，从messagecontroller传过来的
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        
               
        if message.fromId == Auth.auth().currentUser?.uid{
                   //outgoing blue
                   cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
                   cell.textView.textColor = UIColor.white
                  //白字也要重新设置一下，某些特殊情况下点击事件会用到
                  cell.bubbleViewRightAnchor?.isActive = true
                  cell.bubbleViewLeftAnchor?.isActive = false
                  //发信靠右，说不说都行，靠右是messagecell里设置的（默认设置）
                   cell.profileImageView.isHidden = true//发信隐藏左图
               }else{
                   //incomeing gray
                   cell.bubbleView.backgroundColor = UIColor(r:240,g: 240,b: 240)
                   cell.textView.textColor = UIColor.black
                   cell.bubbleViewRightAnchor?.isActive = false
                   cell.bubbleViewLeftAnchor?.isActive = true//收信靠左
                   cell.profileImageView.isHidden = false//收信显示左图
               }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false//可以不写，false是默认的
            cell.messageImageView.backgroundColor = UIColor.clear//是图片棕色背景也去掉
        }else {
            cell.messageImageView.isHidden = true//如果不是图片，让整个messageImageView失效，text不会有棕色背景
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }//不知道什么用

    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) ->CGSize{//气泡高度既每行高度
        var height: CGFloat = 80
        //get estimated height somehow???
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue,let imageHigh = message.imageHigh?.floatValue{
            // h1/w1 = h2/w2
            // solve for h1
            // h1 = h2 /w2 * w1
            height = CGFloat(imageHigh / imageWidth * 200)
           
        }
        
        return CGSize(width: view.frame.width, height:height)//用CGSize设置气泡高度
    }
    
    
    private func estimateFrameForText(text: String) -> CGRect{//得出text的尺寸
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
   var containerViewBottomAnchor: NSLayoutConstraint?
    
   
    
    
    @objc func handleSend(){//输入栏内容存进数据库
        let properties = ["text": inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl:String,image: UIImage){// 发送图片url,和图片尺寸数据
           let properties: [String: AnyObject] = ["imageUrl":imageUrl as AnyObject,"imageWidth": image.size.width as AnyObject,"imageHeight": image.size.height as AnyObject]
           sendMessageWithProperties(properties)
       }
       
       private func sendMessageWithProperties(_ properties: [String: AnyObject]){//从原来的handleSend挪过来的，和sendMessageWithImageUrl基本一样，合到一个func减少代码
              
                     let ref = Database.database().reference().child("messages")
                     let childRef = ref.childByAutoId()//存储多条信息
                     let toId = user!.id!
                     let fromId = Auth.auth().currentUser?.uid
                     let timestamp = Int(Date().timeIntervalSince1970)//1970年到现在的时间（秒）
                     var values : [String: AnyObject] = ["toId": toId as AnyObject,"fromId":fromId as AnyObject,"timestamp":timestamp as AnyObject]
                     //append properties dictionary onto values somehow ??
                     //key $0,value $1
                     properties.forEach({values[$0] = $1})
              
                     childRef.updateChildValues(values) { (error, ref) in//解决每个账号只显示自己的信息
                     if error != nil{
                         print(error as Any)
                         return
                     }
                     self.inputTextField.text = nil//每次发送后清空输入框
                     
                     guard let messageId = childRef.key else { return }//获取messages的messageId（数据库创建每条信息记录时自动生成的）
                     
                     let userMessagesRef =
                         Database.database().reference().child("user-messages").child(fromId!).child(toId).child( messageId)
                     //数据库在user-messages存入messages的messageId（父节点为fromId）及谁发送的信息该信息归谁
                     //16节加入.child(toId)，便于聊天室fetch各自信息
                     userMessagesRef.setValue(1)
                     
                     let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId!).child( messageId)
                      //数据库在user-messages存入messages的messageId（父节点为toId）及谁收到的信息该信息归谁
                     //16节加入.child(fromId)，便于聊天室fetch各自信息
                     recipientUserMessagesRef.setValue(1)
                     //发送者和接收者的MessageController里都有此信息了
                         
                     }
          }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//使用回车
        handleSend()
        return true
    }
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
