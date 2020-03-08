//
//  NewMessageController.swift
//  gameofchats
//
//  Created by No Body on 2020/1/6.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)//和class UserCell有关
        
        fetchUser()
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: {(snapshot)in//获取 name,profileimage,email信息存入Snapshot
            
            if let dictionary = snapshot.value as?[String:AnyObject]{
                let user = User(dictionary: dictionary)//转存进user
                user.id = snapshot.key//id单独获取
                //user.setValuesForKeys(dictionary)//有这个会崩溃，改到在User里面加，
                self.users.append(user)//用户信息存入users
                
               // print(user.name )//if you use this setter,your app will crash if you class properties don't exactly match up with the firebase dictionary keys
                //self.tableView.reloadData()//this will crash because of background thread,so let use dispatch_async to fix
                 DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
   
            }
            //print(snapshot)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 5
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//每行内容
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell//as! UserCell将UITableViewCell指向class UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
//        cell.imageView?.image = UIImage(named:"test")//迁移到usercell class
//        cell.imageView?.contentMode = .scaleAspectFill//原图比例显示
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)//显示用户头像
//            let url = URL(string: profileImageUrl)
//            URLSession.shared.dataTask(with: url!) { (data, response, error) in
//                //download hit an error so lets return out
//                if let error = error{
//                print(error)
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.profileImageView.image = UIImage(data: data!)//显示firebase中的userimage
//                    //cell.imageView?.image =  UIImage(data: data!)
//                }
//            }.resume()
//        }//移入extensions
        }
    return cell
    }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {//加高每行高度
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击跳转到聊天室
        dismiss(animated: true){
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }





}
