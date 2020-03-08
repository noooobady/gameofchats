//
//  ViewController.swift
//  gameofchats
//
//  Created by No Body on 2019/12/27.
//  Copyright © 2019年 No Body. All rights reserved.
//

import UIKit
import Firebase

let cellId = "cellId"


class MessagesController: UITableViewController {//有聊天内容的列表
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target:self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier:  cellId)
        //引用UserCell（包含了聊天对象名字和头像）
        
        //observeMessages()
        //observeUserMessage()
        
    }

    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessage(){//获取当前用户的聊天信息
        guard let uid = Auth.auth().currentUser?.uid else {//获取当前用户的id
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with:{ (snapshot) in//进入第二层，当前用户ID层
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in//在16节后user-message加入了toId层，在此进入toId层,减少了流量开销
                print(snapshot)//snapshot内容是当前用户和user的message的ID（key）
                let messageId = snapshot.key
                //获取当前用户的获取messageId（userId的child），参见ChatLogController的handleSend
                let messagesReference = Database.database().reference().child("messages").child(messageId)
                messagesReference.observe(.value, with: { (snapshot) in//获取当前用户的聊天信息
                    //print(snapshot)
                    if let dictionary = snapshot.value as?[String:AnyObject]{
                    let message = Message(dictionary: dictionary)//转存进message用Message的格式
                        //self.messages.append(message)//转存进messages
                         let chatPartnerId = message.chatPartnerId()//用chatPartnerId换掉toid防止两人对话产生两个窗口
                            self.messagesDictionary[chatPartnerId] = message//messagesDictionary将各自信息归于各自一个人下
                        
                            self.attemptReloadOfTable()
     
                    }
                }, withCancel: nil)
                
            }, withCancel: nil)
 
        }, withCancel: nil)
        
       }
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()//从observeUserMessage转到这
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        //修复firebase多次relode，导致用户头像错误的bug
    }
    
     var timer: Timer?
    
    @objc func handleReloadTable() {//受attemptReloadOfTable()的时间控制，减少sort的开销
           self.messages = Array(self.messagesDictionary.values)//转存进messages,从observeUserMessage转到这
           self.messages.sort (by:{ (message1, message2) -> Bool in//按照时间降序排列,从observeUserMessage转到这
               return message1.timestamp!.int32Value > message2.timestamp!.int32Value
           })
           //this will crash because of background thread, so lets call this on dispatch_async main thread
           DispatchQueue.main.async(execute: {
               self.tableView.reloadData()
           })
       }
    
//    func observeMessages(){//获取全部聊天信息
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in//数据存入snapshot
//            if let dictionary = snapshot.value as?[String:AnyObject]{
//            let message = Message(dictionary: dictionary)//转存进message用Message的格式
//                //self.messages.append(message)//转存进messages
//                if let toId = message.toId{
//                    self.messagesDictionary[toId] = message//messagesDictionary将各自信息归于各自一个人下
//                    self.messages = Array(self.messagesDictionary.values)//转存进messages
//                    self.messages.sort (by:{ (message1, message2) -> Bool in//按照时间降序排列
//                        return message1.timestamp!.int32Value > message2.timestamp!.int32Value
//                    })
//                }
//                //self.tableView.reloadData()//this will crash because of background thread,so let use  DispatchQueue to fix
//                DispatchQueue.main.async(execute: {
//                self.tableView.reloadData()
//                })
//                //print(message.text)
//            }
//            
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {//加高每行高度
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//定行数
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//定内容
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! UserCell//引用UserCell
        let message = messages[indexPath.row]
        cell.message = message//执行Usercell
        //cell.textLabel?.text = message.toId
/*        if let toId = message.toId{//获取名字//////////移入UserCell
            let ref = Database.database().reference().child("users").child(toId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    cell.textLabel?.text = dictionary["name"] as?String

                    if let profileImageUrl = dictionary["profileImageUrl"]{
                        cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl as! String)
                    }
                }
                //print(snapshot)
            }, withCancel: nil)
        }
            cell.detailTextLabel?.text = message.text
 */
          return cell//执行Usercell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击进入聊天室
        let message = messages[indexPath.row]
        //print(messa ge.text,message.toId,message.fromId)
        let chatPartnerId = message.chatPartnerId()
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            guard let dictionary = snapshot.value as?[String:AnyObject]
                else {
                    return
            }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId//snapshot中没有ID，单独加
            self.showChatControllerForUser(user)//用所选项用户的信息进入聊天界面
        }, withCancel: nil)
    }
    
    
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self//激活newMessageController的self，让newMessageController中可以用MessageController的方程
        //let navController = UINavigationController(rootViewController: newMessageController)
        present(newMessageController, animated: true, completion: nil)
    }
    
    
    @objc func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupNavBarTitle()
        }
  
   }
   
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else{
            //for some reason uid = nil
            return
        }
      Database.database().reference().child("users").child(uid).observeSingleEvent(of:.value, with: {(Snapshot) in//获取当前用户信息存入Snapshot
               // print(Snapshot)
                if let dictionary = Snapshot.value as?[String: AnyObject]{
                   // self.navigationItem.title = dictionary["name"] as? String
                    
                    let user = User(dictionary: dictionary)
                    //user.setValuesForKeys(dictionary)//有这句会崩溃
                    self.setupNavBarWithUser(user)//设置title
                    
                }
            
            }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User){//修饰MessageController的title
        //self.navigationItem.title = user.name
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessage()//修复数据库删掉聊天信息后重新登入老信息还在的bug
        
     
        let titleView = UIView()//titleView是总框架
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)//居中，宽100，高40
        //titleView.backgroundColor =  UIColor.red

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)//二级框架，未定宽高，让namelabel可以无限往右
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false//没有这句后面无法isActive
        profileImageView.contentMode = .scaleToFill//让title图
        profileImageView.layer.cornerRadius = 20//变
        profileImageView.clipsToBounds = true//圆

        if let profileImageUrl = user.profileImageUrl{//获取图片下载url，下图
                    profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
               }

               containerView.addSubview(profileImageView)//加进containerView
               //修饰profileImageView
               profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
               //靠到titleView最左
               profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
               profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
               profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)//定义后立刻加到containerView,不然会崩溃
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false//没有这句后面无法isActive
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true//技巧点,最右无止境
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        self.navigationItem.titleView = titleView

//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        ////////////////////////////
//        let button = UIButton(type: .system)
//        button.setTitle(user.name, for: .normal)
//        button.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
//
//        self.navigationItem.titleView = button

    }
    @objc func showChatControllerForUser(_ user: User) {
           let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user 
           navigationController?.pushViewController(chatLogController, animated: true)
        // present(chatLogController, animated: true, completion: nil)用这个会崩溃，没有初始化
       }
    
    @objc func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        
        present(loginController,animated: true, completion: nil)
    }
 
}
