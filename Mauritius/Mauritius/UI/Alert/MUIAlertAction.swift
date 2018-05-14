//
//  MUIAlertAction.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/1/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

public enum MUIAlertActionStyle: Int {
    case normal
    case cancel
}

/// An action that can be taken when the user taps a button in an MUIAlertController
open class MUIAlertAction: UIButton {
    
    // MARK: - Properties
    internal var action: (() -> Void)?
    
    public var title: String? {
        willSet {
            setTitle(newValue, for: .normal)
        }
    }
    
    public var titleColor: UIColor? {
        willSet {
            setTitleColor(newValue, for: .normal)
        }
    }
    
    public var titleFont: UIFont? {
        willSet {
            self.titleLabel?.font = newValue
        }
    }
    
    public var actionBackgroundColor: UIColor? {
        willSet {
            backgroundColor = newValue
        }
    }
    
    // MARK: - Initializers
    required public  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(title: String, titleColor: UIColor) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
    }
    
    public convenience init(title: String, style: MUIAlertActionStyle, action: (() -> Void)? = nil) {
        self.init(type: .system)
        
        self.action = action
        self.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        
        switch style {
        case .normal:
            setTitle(title: title, forStyle: .normal)
            
        case .cancel:
            setTitle(title: title, forStyle: .cancel)
        }
    }
}

internal extension MUIAlertAction {
    
    fileprivate func setTitle(title: String, forStyle: MUIAlertActionStyle) {
        self.setTitle(title, for: .normal)
        addSeparator()
        
        switch forStyle {
        case .normal:
            setTitleColor(UIColor.muiActionColor, for: .normal)
            titleFont = UIFont.boldSystemFont(ofSize: 16)
            
        case .cancel:
            setTitleColor(UIColor.muiCancelColor, for: .normal)
            titleFont = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    fileprivate func addSeparator() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.muiSeparatorColor.withAlphaComponent(0.4)
        
        self.addSubview(separator)
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    @objc func actionTapped(sender: MUIAlertAction) {
        self.action?()
    }
}
