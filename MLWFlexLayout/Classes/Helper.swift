//
//  Helper.swift
//  layout
//
//  Created by Milo on 2020/8/22.
//  Copyright © 2020 Milo. All rights reserved.
//

import Foundation
import UIKit

protocol UILayoutGuideProtocol {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    
    var leftAnchor: NSLayoutXAxisAnchor { get }
    
    var rightAnchor: NSLayoutXAxisAnchor { get }
    
    var topAnchor: NSLayoutYAxisAnchor { get }
    
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    
    var widthAnchor: NSLayoutDimension { get }
    
    var heightAnchor: NSLayoutDimension { get }
    
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UILayoutGuideProtocol {
    func fill(_ layout: UILayoutGuideProtocol, priority: Float = UILayoutPriority.required.rawValue) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: layout.topAnchor).setPriority(priority),
            leftAnchor.constraint(equalTo: layout.leftAnchor).setPriority(priority),
            bottomAnchor.constraint(equalTo: layout.bottomAnchor).setPriority(priority),
            rightAnchor.constraint(equalTo: layout.rightAnchor).setPriority(priority),
        ]
    }
}

extension UILayoutGuide: UILayoutGuideProtocol {}
extension UIView: UILayoutGuideProtocol {}
extension UIView {
    func animateUpdateConstraints(duration: TimeInterval, animation: @escaping ()->Void) {
        animation()
        setNeedsUpdateConstraints()
        Self.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}

extension NSLayoutConstraint {
    func setIdentifider(_ id: String?) -> NSLayoutConstraint {
        identifier = id
        return self
    }
    
    func setPriority(_ p: Float) -> NSLayoutConstraint {
        priority = UILayoutPriority(rawValue: p)
        return self
    }
}
