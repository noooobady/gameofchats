//
//  LoginController.swift
//  gameofchats
//
//  Created by No Body on 2019/12/27.
//  Copyright © 2019年 No Body. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {
    
    var messagesController: MessagesController?
    
    
    let inputsContainView: UIView = {
        let view=UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry=true
        return tf
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
  
    
    lazy var loginRegisterSegementedControl:UISegmentedControl = {
        let sc = UISegmentedControl(items:["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints=false
        //sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for:.valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegementedControl.titleForSegment(at: loginRegisterSegementedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControl.State())
        //change hight of inputContainView,but how?
        inputsContainerViewHeihtAnchor?.constant = loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 100 :150
        //change height nametextfield
        nameTextFieldHeightAnchor?.isActive=false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 0: 1/3)
               nameTextFieldHeightAnchor?.isActive = true
        //change height emailtextfield
        emailTextFieldHeightAnchor?.isActive=false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2: 1/3)
               emailTextFieldHeightAnchor?.isActive = true
        //change height passwordtextfield
        passwordTextFieldHeightAnchor?.isActive=false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2: 1/3)
               passwordTextFieldHeightAnchor?.isActive = true
        //print(loginRegisterSegementedControl.selectedSegmentIndex)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegementedControl)
        view.addSubview(profileImageView)
    
        setupInputsContainerView()
        setupLoginRegisterButton()
        setuploginRegisterSegementedControl()
        setupProfileImageView()
        
        
        
        
    }
    

    func setuploginRegisterSegementedControl(){
        //need x, y, width,hight contrains
         
    loginRegisterSegementedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
    loginRegisterSegementedControl.bottomAnchor.constraint(equalTo: inputsContainView.topAnchor, constant: -12).isActive=true
    loginRegisterSegementedControl.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
    loginRegisterSegementedControl.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
    }
    
    func setupProfileImageView(){
        //need x, y, width,hight contrains
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegementedControl.topAnchor, constant: -12).isActive=true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive=true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive=true
    }
    
    var inputsContainerViewHeihtAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor:NSLayoutConstraint?
    
    func setupInputsContainerView(){
        //need x, y, width,hight contrains
        inputsContainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        inputsContainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        inputsContainView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive=true
        
        inputsContainerViewHeihtAnchor = inputsContainView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeihtAnchor?.isActive=true
        
        inputsContainView.addSubview(nameTextField)
        inputsContainView.addSubview(nameSeparatorView)
        inputsContainView.addSubview(emailTextField)
        inputsContainView.addSubview(emailSeparatorView)
        inputsContainView.addSubview(passwordTextField)
        
        //need x, y, width,hight contrains
        nameTextField.leftAnchor.constraint(equalTo: inputsContainView.leftAnchor, constant: 12).isActive=true
        nameTextField.topAnchor.constraint(equalTo: inputsContainView.topAnchor).isActive=true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive=true
        
        //need x, y, width,hight contrains
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainView.leftAnchor).isActive=true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive=true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
        //need x, y, width,hight contrains
        emailTextField.leftAnchor.constraint(equalTo: inputsContainView.leftAnchor, constant: 12).isActive=true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive=true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        
        emailTextFieldHeightAnchor=emailTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive=true
        
        //need x, y, width,hight contrains
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainView.leftAnchor).isActive=true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive=true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
        //need x, y, width,hight contrains
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainView.leftAnchor, constant: 12).isActive=true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive=true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive=true
    }
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegementedControl.selectedSegmentIndex == 0{
            handleLogin()
        }
        else {
            handleRegister()
        }
    }
    
     func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user,error) in
            if let error = error {
                print(error)
                return
            }
            //successfully login user
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            //登陆时就更新messagesController的头名，头名不改的bug修复
        self.dismiss(animated: true, completion: nil)
        })
        
    }
    
     
    
    
    func setupLoginRegisterButton() {
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainView.bottomAnchor, constant: 12).isActive=true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainView.widthAnchor).isActive=true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 30).isActive=true
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}



