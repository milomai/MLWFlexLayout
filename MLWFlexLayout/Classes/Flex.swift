//
//  Flex.swift
//  layout
//
//  Created by Milo on 2020/8/22.
//  Copyright © 2020 Milo. All rights reserved.
//

import UIKit

protocol FlexObserverProtocol : class {
    func childrenFlexChanged()
}

public class Flex: UILayoutGuide {
    fileprivate var WidthConstraintId = "Flex-Width"
    fileprivate var HeightConstraintId = "Flex-Height"
    
    public var flex: CGFloat {
        didSet {
            flexObserver?.childrenFlexChanged()
        }
    }
    
    /// the view in this layout
    public var view: UIView?
    public var width: CGFloat {
        get { widthConstraint?.constant ?? 0}
        set { widthConstraint?.constant = newValue }
    }
    public var height: CGFloat {
        get { heightConstraint?.constant ?? 0}
        set { heightConstraint?.constant = newValue }
    }
    
    public var isActive: Bool = false {
        didSet {
            guard owningView != nil else {
                print("set active to unanchor layout is no effect")
                return
            }
            zeroConstraints.forEach {$0.isActive = !isActive}
        }
    }
    
    fileprivate var children: [Flex] = []
    fileprivate var constraints: [NSLayoutConstraint] = []
    fileprivate var widthConstraint: NSLayoutConstraint? {
        get {
            constraints.first { $0.identifier == WidthConstraintId }
        }
    }
    fileprivate var heightConstraint: NSLayoutConstraint? {
        get {
            constraints.first { $0.identifier == HeightConstraintId }
        }
    }
    fileprivate weak var flexObserver: FlexObserverProtocol?
    fileprivate lazy var zeroConstraints: [NSLayoutConstraint] = [
        widthAnchor.constraint(equalToConstant: 0),
        heightAnchor.constraint(equalToConstant: 0)
    ]
    
    private lazy var debugView: UIView = {
        let color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        let view = UIView()
        view.accessibilityIdentifier = "\(Self.description())"
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 1
        
        return view
    } ()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(_ flex: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, view: UIView? = nil, child: Flex? = nil) {
        self.flex = flex
        super.init()
        
        if width != 0 {
            constraints.append(widthAnchor.constraint(equalToConstant: width).setIdentifider(WidthConstraintId))
        }
        if height != 0 {
            constraints.append(heightAnchor.constraint(equalToConstant: height).setIdentifider(HeightConstraintId))
        }
        
        view?.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
        if let _view = view {
            if flex == 0 && width == 0 && height == 0 {
                constraints.append(contentsOf: [
                    _view.topAnchor.constraint(equalTo: topAnchor),
                    _view.leftAnchor.constraint(equalTo: leftAnchor),
                    heightAnchor.constraint(equalTo: _view.heightAnchor).setIdentifider(HeightConstraintId),
                    widthAnchor.constraint(equalTo: _view.widthAnchor).setIdentifider(WidthConstraintId)
                ])
            } else {
                constraints.append(contentsOf: view!.fill(self))
            }
        }
        
        if child != nil {
            children.append(child!)
            constraints.append(contentsOf:child!.fill(self))
        }
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - flex: the grow value, default is 0
    ///   - width: default is 0
    ///   - height: default is 0
    ///   - view: the view in this layout, if both flex, width & height is zero, will use view's intrinsicContentSize as layout size, otherwise the view will fill the layout size
    ///   - ref: refrence to this layout
    ///   - child: child layout
    public convenience init(_ flex: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, view: UIView? = nil, ref: inout Flex?, child: Flex? = nil) {
        self.init(flex, width:width, height:height, view:view, child:child)
        ref = self
    }
    
    public func debugDraw() {
        owningView?.addSubview(debugView)
        NSLayoutConstraint.activate(debugView.fill(self))
        children.forEach { $0.debugDraw() }
    }
    
    fileprivate func activeConstrains() {
        NSLayoutConstraint.activate(constraints)
        children.forEach {$0.activeConstrains()}
    }
    
    private func anchorToView(_ view: UIView) {
        view.addLayoutGuide(self)
        children.forEach {$0.anchorToView(view)}
        
        if self.view != nil {
            view.addSubview(self.view!)
        }
    }
    
    
    /// Set as root layout, will fill the root view
    /// - Parameter root: the view own this layout
    public func setRootView(_ root: UIView) {
        anchorToView(root)
        activeConstrains()
        NSLayoutConstraint.activate(fill(root))
    }
    
    // MARK: -
    struct DirectionAnchor {
        var start: NSLayoutAnchor<AnyObject>
        var space: NSLayoutDimension
        var spaceConstraint: NSLayoutConstraint?
        var center: NSLayoutAnchor<AnyObject>
        var end: NSLayoutAnchor<AnyObject>
    }
    
    struct Axis {
        var main: DirectionAnchor
        var cross: DirectionAnchor
    }
    
    var h: DirectionAnchor {
        DirectionAnchor(
            start: unsafeDowncast(leftAnchor, to: NSLayoutAnchor<AnyObject>.self),
            space: widthAnchor,
            spaceConstraint: widthConstraint,
            center: unsafeDowncast(centerXAnchor, to: NSLayoutAnchor<AnyObject>.self),
            end: unsafeDowncast(rightAnchor, to: NSLayoutAnchor<AnyObject>.self))
    }
    
    var v: DirectionAnchor {
        DirectionAnchor(
            start: unsafeDowncast(topAnchor, to: NSLayoutAnchor<AnyObject>.self),
            space: heightAnchor,
            spaceConstraint: heightConstraint,
            center: unsafeDowncast(centerYAnchor, to: NSLayoutAnchor<AnyObject>.self),
            end: unsafeDowncast(bottomAnchor, to: NSLayoutAnchor<AnyObject>.self))
    }
    
    func anchorsFor(_ direction: DirectionFlexLayout.Direction) -> Axis {
        switch direction {
        case .row:
            return Axis(main: h, cross: v)
        case .column:
            return Axis(main: v, cross: h)
        }
    }
}

public class DirectionFlexLayout: Flex, FlexObserverProtocol {
    public enum Direction {
        case row
        case column
    }
    
    public enum MainAxisAlignment {
        case start
        case center
        //        case end
        //        case sapceAround
        case spaceBetween
        //        case spaceEqually
    }
    
    public enum crossAxisAlignment {
        //        case start
        case center
        //        case end
        case stretch
    }
    
    public var direction: Direction
    
    private var flexConstraints: [NSLayoutConstraint] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(direction: Direction,
                     flex: CGFloat = 0,
                     width: CGFloat = 0,
                     height: CGFloat = 0,
                     mainAlignment:MainAxisAlignment = .start,
                     crossAlignment:crossAxisAlignment = .stretch,
                     ref: inout DirectionFlexLayout?,
                     children: [Flex] = []) {
        self.init(direction: direction,
                  flex: flex,
                  width: width,
                  height: height,
                  mainAlignment: mainAlignment,
                  crossAlignment: crossAlignment,
                  children: children
        )
        ref = self
    }
    
    public init(direction: Direction,
         flex: CGFloat = 0,
         width: CGFloat = 0,
         height: CGFloat = 0,
         mainAlignment:MainAxisAlignment = .start,
         crossAlignment:crossAxisAlignment = .stretch,
         children: [Flex] = []) {
        self.direction = direction
        super.init(flex, width: width, height: height)
        
        func installCrossAlignmentConstraints(_ child: Flex) {
            switch crossAlignment {
            case .stretch:
                constraints.append(contentsOf: [
                    child.anchorsFor(direction).cross.space.constraint(equalTo: anchorsFor(direction).cross.space).setPriority(999),
                    child.anchorsFor(direction).cross.start.constraint(equalTo: anchorsFor(direction).cross.start)
                ])
            case .center:
                constraints.append(child.anchorsFor(direction).cross.center.constraint(equalTo: anchorsFor(direction).cross.center).setPriority(999))
            }
        }
        
        var spaces: [Flex] = [] // use to set main axis alignment
        let hasFlex = children.contains { $0.flex > 0 }
        
        if !hasFlex {
            let start = Flex()
            self.children.append(start)
            spaces.append(start)
            for child in children {
                self.children.append(child)
                let space = Flex()
                self.children.append(space)
                spaces.append(space)
            }
        } else {
            self.children = children
        }
        
        for (index, child) in self.children.enumerated() {
            child.flexObserver = self
            installCrossAlignmentConstraints(child)
            
            if index == 0 {
                constraints.append(child.anchorsFor(direction).main.start.constraint(equalTo: anchorsFor(direction).main.start))
            } else {
                let previous = self.children[index-1]
                constraints.append(child.anchorsFor(direction).main.start.constraint(equalTo: previous.anchorsFor(direction).main.end))
            }
        }
        childrenFlexChanged()
        
        func setMainAxisAlignment() {
            let start = spaces.first!
            let end = spaces.last!
            switch mainAlignment {
            case .start:
                constraints.append(contentsOf: [
                    end.anchorsFor(direction).main.end.constraint(equalTo: anchorsFor(direction).main.end).setPriority(900)
                ])
            case .center:
                constraints.append(contentsOf: [
                    start.anchorsFor(direction).main.space.constraint(equalTo: end.anchorsFor(direction).main.space).setPriority(900)
                ])
            case .spaceBetween:
                var consts: [NSLayoutConstraint] = [
                    start.anchorsFor(direction).main.space.constraint(equalToConstant: 0),
                    end.anchorsFor(direction).main.space.constraint(equalToConstant: 0),
                ]
                for (index, child) in spaces.enumerated() {
                    if index > 1 && index < spaces.count - 1 {
                        consts.append(child.anchorsFor(direction).main.space.constraint(equalTo: spaces[1].anchorsFor(direction).main.space))
                    }
                }
                consts.forEach {$0.priority = UILayoutPriority(rawValue: 900)}
                constraints.append(contentsOf: consts)
            }
        }
        
        // main axis alignment has no effect if there has any flex child
        if !hasFlex {
            setMainAxisAlignment()
        }
        
        let layout = anchorsFor(direction).main.end.constraint(equalTo: children.last!.anchorsFor(direction).main.end)
        layout.identifier = "\(Self.self).end"
        layout.priority = UILayoutPriority(rawValue: 888)
        constraints.append(layout)
    }
    
    // to support dynamic flex, WIP
    func childrenFlexChanged() {
        // remove old
        constraints.removeAll { flexConstraints.contains($0) }
        flexConstraints.forEach {
            owningView?.removeConstraint($0)
        }
        flexConstraints.removeAll()
        
        // add new
        var baseFlexLayout: Flex!
        children.forEach { child in
            if child.flex > 0 {
                if baseFlexLayout == nil {
                    baseFlexLayout = child
                }
                let multiplier = CGFloat(child.flex)/CGFloat(baseFlexLayout.flex)
                flexConstraints.append(child.anchorsFor(direction).main.space.constraint(equalTo: baseFlexLayout.anchorsFor(direction).main.space, multiplier: multiplier))
            }
        }
        
        constraints.append(contentsOf: flexConstraints)
        if owningView != nil {
            activeConstrains()
        }
    }
}

public class Row: DirectionFlexLayout {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(flex: CGFloat = 0,
         width: CGFloat = 0,
         height: CGFloat = 0,
         mainAlignment:MainAxisAlignment = .start,
         crossAlignment:crossAxisAlignment = .stretch,
         _ children: [Flex] = []) {
        super.init(direction: .row,
                   flex: flex,
                   width: width,
                   height: height,
                   mainAlignment: mainAlignment,
                   crossAlignment: crossAlignment,
                   children: children)
    }
    
    public convenience init(flex: CGFloat = 0,
                     width: CGFloat = 0,
                     height: CGFloat = 0,
                     mainAlignment:MainAxisAlignment = .start,
                     crossAlignment:crossAxisAlignment = .stretch,
                     ref: inout Row?,
                     _ children: [Flex] = []) {
        self.init(flex: flex,
                  width: width,
                  height: height,
                  mainAlignment: mainAlignment,
                  crossAlignment: crossAlignment,
                  children
        )
        ref = self
    }
}

public class Column: DirectionFlexLayout {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(flex: CGFloat = 0,
         width: CGFloat = 0,
         height: CGFloat = 0,
         mainAlignment:MainAxisAlignment = .start,
         crossAlignment:crossAxisAlignment = .stretch,
         _ children: [Flex] = []) {
        super.init(direction: .column,
                   flex: flex,
                   width: width,
                   height: height,
                   mainAlignment: mainAlignment,
                   crossAlignment: crossAlignment,
                   children: children)
    }
    
    public convenience init(flex: CGFloat = 0,
                     width: CGFloat = 0,
                     height: CGFloat = 0,
                     mainAlignment:MainAxisAlignment = .start,
                     crossAlignment:crossAxisAlignment = .stretch,
                     ref: inout Column?,
                     _ children: [Flex] = []) {
        self.init(flex: flex,
                  width: width,
                  height: height,
                  mainAlignment: mainAlignment,
                  crossAlignment: crossAlignment,
                  children
        )
        ref = self
    }
}

public class Spacer: Flex {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(_ space: CGFloat) {
        super.init(width: space, height: space)
    }
}

public class Center: Flex {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(view: UIView? = nil, child: Flex? = nil) {
        super.init(1, child: Column([
            Flex(1),
            Row([
                Flex(1),
                Flex(view: view, child: child),
                Flex(1),
            ]),
            Flex(1),
        ]))
    }
}
