//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by No Body on 2020/1/7.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit
import Firebase
extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (res, error) in
            if let error = error {
                print(error)
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            //successfully authenticated user
        let imageName = NSUUID().uuidString//给每个图片唯一编码
        let storageRef = Storage.storage().reference().child("UserImage").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
       // if let uploadData = self.profileImageView.image!.pngData(){
               storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                   if let error = error {
                       print(error)
                       return
                   }
                   storageRef.downloadURL(completion: { (url, err) in
                       if let err = err {
                           print(err)
                           return
                       }
                       guard let url = url else { return }
                       let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
                       self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                   })
               })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(_ uid:String,values:[String:AnyObject]){
        //let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            print("Saved user successfully into Firebase db")
            //self.messagesController?.fetchUserAndSetupNavBarTitle()
            //self.messagesController?.navigationController?.title = values["name"]as? String
            let user = User(dictionary: values)
            self.messagesController?.setupNavBarWithUser(user) //存进数据库时就更新messagesController的头名，头名不改的bug修复,直接用输入栏的名字，不用fetch数据库
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView(){//总选图
            //print(123)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
       }
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {//选图控制
        //print(info)
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)//下面的4.2方程
        
         var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"]as? UIImage{//相册中选图传给editedImage
            //print(editedImage.size)
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"]as? UIImage{
            //print(originaLImage.size)
            selectedImageFromPicker = originalImage
        }
        //profileImageView.image = selectedImageFromPicker
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
       dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.//没有下面这些。info中括号后面的就需要改为.editedimage/.originalimage
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
