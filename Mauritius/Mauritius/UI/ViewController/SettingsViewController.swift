//
//  SettingsViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/12/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class MUITextField: UITextField {
    convenience init(frame: CGRect, placeholder: String, icon: UIImage) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.darkGray
        self.borderStyle = .none
        self.placeholder = placeholder
        self.font = UIFont.systemFont(ofSize: 15)
        
        let leftViewRect = UIView(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height))

        let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: (leftViewRect.bounds.height/2), height: (leftViewRect.bounds.height/2)))
        leftIconView.image = icon.withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.gray)
        leftIconView.contentMode = .scaleAspectFit
        leftIconView.center = CGPoint(x: leftViewRect.frame.width/2, y: leftViewRect.frame.height/2)
        leftViewRect.addSubview(leftIconView)
        
//        let separator = UIView(frame: CGRect.init(x: leftViewRect.frame.width - 3, y: 0, width: 0.75, height: self.frame.height/3))
//        separator.center.y = leftViewRect.frame.height/2
//        separator.backgroundColor = UIColor.lightGray
//        leftViewRect.addSubview(separator)
        
        self.leftView = leftViewRect
        self.leftViewMode = .always
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, leftView!.frame.width, 0, 10))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, leftView!.frame.width, 0, 10))
    }
}

class TextFieldsView: UIView {
    var nameField: MUITextField!
    var emailField: MUITextField!
    var contactField: MUITextField!
    
    convenience init(frame: CGRect, delegate: UITextFieldDelegate) {
        self.init(frame: frame)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.backgroundColor = UIColor(hexString: "#F5F6F7ff")!
        
        nameField = MUITextField(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: 60), placeholder: "Full Name", icon: #imageLiteral(resourceName: "icon-name"))
        nameField.delegate = delegate
        nameField.tag = 100
        nameField.returnKeyType = .next
        self.addSubview(nameField)
        let separator = UIView(frame: CGRect.init(x: 0, y: nameField.frame.height, width: frame.width, height: 2))
        separator.backgroundColor = UIColor.white
        self.addSubview(separator)
        
        emailField = MUITextField(frame: CGRect.init(x: 0, y: separator.frame.origin.y + 2 , width: frame.width, height: 60), placeholder: "Email", icon: #imageLiteral(resourceName: "icon-email"))
        emailField.delegate = delegate
        emailField.tag = 101
        emailField.returnKeyType = .next
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.keyboardType = .emailAddress
        self.addSubview(emailField)
        let separator2 = UIView(frame: CGRect.init(x: 0, y: emailField.frame.origin.y + emailField.frame.height, width: frame.width, height: 2))
        separator2.backgroundColor = UIColor.white
        self.addSubview(separator2)
        
        contactField = MUITextField(frame: CGRect.init(x: 0, y: separator2.frame.origin.y + 2 , width: frame.width, height: 60), placeholder: "Phone", icon: #imageLiteral(resourceName: "icons-phone"))
        contactField.delegate = delegate
        contactField.tag = 102
        contactField.returnKeyType = .done
        self.addSubview(contactField)

    }
    
}

class MAnimatedButton: UIControl {
    private var textLabel: UILabel!
    private var imageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView?
    private var originalWidth: CGFloat = 0
    private var originalBG: UIColor = UIColor.white
    
    var status: (image: UIImage, color: UIColor?)? {
        didSet {
            if let image_ = status?.image {
                self.setStatus(with: image_, color: status?.color ??  self.backgroundColor)
            }
        }
    }
    
    convenience init(frame: CGRect, title: String, color: UIColor) {
        self.init(frame: frame)
        
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        self.backgroundColor = color
        self.originalBG = color
        self.originalWidth = self.frame.width
        
        textLabel = UILabel(frame: self.bounds)
        textLabel.font = UIFont.boldSystemFont(ofSize: 18)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.text = title
        textLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(textLabel)
        
        self.addTarget(self, action: #selector(self.onTouchDown(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.onTouchCancel(sender:)), for: [.touchDragExit, .touchDragOutside, .touchUpInside, .touchUpOutside, .touchCancel])
        self.addTarget(self, action: #selector(self.OnTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    @objc func onTouchDown(sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 0.6
        }
    }
    
    @objc func onTouchCancel(sender: UIControl) {
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 1.0
        }
    }
    
    @objc func OnTouchUpInside(sender: UIControl) {
        self.isUserInteractionEnabled = false
        self.textLabel.alpha = 0
        //Animate and start loading view
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        activityIndicator?.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        activityIndicator?.startAnimating()
        self.addSubview(activityIndicator!)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.size.width = self.frame.height
            self.activityIndicator?.center.x = self.frame.width/2
            self.center.x = self.superview!.frame.width/2
        }) { (_) in
            //Customize here after animation completion
        }
    }
    
    private func setStatus(with image: UIImage, color: UIColor?) {
        self.activityIndicator?.stopAnimating()
        imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.frame.height/2, height: self.frame.height/2))
        imageView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.image = image.withRenderingMode(.alwaysTemplate).tintWithColor(.white)
        self.addSubview(imageView)
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.alpha = 1.0
            self.backgroundColor = color
        }) { (_) in
            self.activityIndicator?.removeFromSuperview()
            delay(0.6, closure: {
                self.finish()
            })
        }
    }
    
    func finish() {
        self.activityIndicator?.removeFromSuperview()
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundColor = self.originalBG
            self.frame.size.width = self.originalWidth
            self.center.x = self.superview!.frame.width/2
            self.textLabel.alpha = 1.0
        }) { (_) in
            self.isUserInteractionEnabled = true
        }
    }
}

class SettingsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var floatingImage: UIImageView!
    var saveButton: MAnimatedButton!
    var textFields = [UITextField]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.view.backgroundColor = UIColor.white
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        let fieldsView = TextFieldsView(frame: CGRect.init(x: 20, y: 0, width: self.view.frame.width - 40, height: 186), delegate: self)
        self.textFields.append(fieldsView.nameField)
        self.textFields.append(fieldsView.emailField)
        self.textFields.append(fieldsView.contactField)
        scrollView.addSubview(fieldsView)
        scrollView.contentSize.height += fieldsView.frame.height
        
        floatingImage = UIImageView(frame: CGRect.init(x: 0, y:0, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height/3)))
        floatingImage.image = UIImage.gif(url: "https://cdn.dribbble.com/users/310943/screenshots/2422843/save-for-later-loop.gif")
        floatingImage.contentMode = .scaleAspectFit
        floatingImage.frame.origin.y = self.view.frame.height - floatingImage.frame.height - (self.navigationController?.navigationBar.frame.maxY ?? 64)
        floatingImage.layer.cornerRadius = 4
        floatingImage.clipsToBounds = true
        self.view.insertSubview(floatingImage, belowSubview: scrollView)
        
        saveButton = MAnimatedButton(frame: CGRect.init(x: 0, y: 0, width: 180, height: 50), title: "Save", color: UIColor(hexString: "#60D574FF")!)
        saveButton.center.x = self.view.frame.width/2
        saveButton.frame.origin.y = fieldsView.frame.origin.y + fieldsView.frame.height + 30
        saveButton.addTarget(self, action: #selector(self.saveData), for: .touchUpInside)
        self.scrollView.addSubview(saveButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = UserManager.shared.currentUser {
            self.textFields[0].placeholder = user.username ?? "Full Name"
            self.textFields[1].placeholder = user.email
            self.textFields[2].placeholder = user.phone ?? "Phone"
        }
    }
    
    @objc func saveData() {
        if let email = self.textFields[1].text {
            if !self.isValidEmail(str: email) {
                delay(0.5, closure: {
                    self.saveButton.finish()
                })
                Utility.alert(with: "Oops!", message: "Please enter a valid email.", type: .info)
                return
            }
            UserManager.shared.createUser(name: self.textFields[0].text, email: email, contact: self.textFields[2].text, completion: { (user, error) in
                if error != nil {
                    self.saveButton.finish()
                    Utility.alert(with: "Oops!", message: "Something went wrong. Please try again.", type: .error)
                }else {
                    self.saveButton.status = (#imageLiteral(resourceName: "ok"), nil)
                }
            })
        }else {
            Utility.alert(with: "Error", message: "Please enter your email.", type: .info)
            delay(0.5, closure: {
                self.saveButton.finish()
            })
        }
        
    }
    
    func isValidEmail(str: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: str)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for item in textFields {
            item.resignFirstResponder()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -30 {
            for item in textFields {
                item.resignFirstResponder()
            }
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Clean up responder logic later
        if textField.tag == 100 {
            self.textFields[1].becomeFirstResponder()
        }else  if textField.tag == 101 {
            self.textFields[2].becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
 
}
