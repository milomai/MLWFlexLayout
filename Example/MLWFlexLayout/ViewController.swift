//
//  ViewController.swift
//  MLWFlexLayout
//
//  Created by Milo Mai on 08/23/2020.
//  Copyright (c) 2020 Milo Mai. All rights reserved.
//

import UIKit
import MLWFlexLayout

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var otherLoginWaysLayout: Row?
        var blueButton: Flex?
        var pinkButton: Flex?
        
        let flex = Column(crossAlignment: .center, [
            Spacer(100),
            Flex(view: {
                let label = UILabel()
                label.text = "Sign in"
                label.font = .boldSystemFont(ofSize: 24)
                return label
            } ()),
            Spacer(100),
            Column(width: 300, [
                Flex(view: {
                    let textfield = UITextField()
                    textfield.placeholder = "username"
                    return textfield
                } ()),
                Spacer(10),
                Flex(view: {
                    let textfield = UITextField()
                    textfield.placeholder = "password"
                    return textfield
                } ()),
            ]),
            Spacer(30),
            Column(width: 300, crossAlignment: .center, [
                Flex(view: {
                    let label = UILabel()
                    label.text = "Other login way"
                    label.textColor = .systemGray
                    label.font = .systemFont(ofSize: 12)
                    return label
                } ()),
                Spacer(10),
                Row(width: 260, height: 0, mainAlignment: .spaceBetween, ref:&otherLoginWaysLayout, [
                    Flex(1, view: {
                        let button = UIButton(type: .system)
                        button.backgroundColor = .cyan
                        return button
                    } ()),
                    Flex(1, view: {
                        let button = UIButton(type: .system)
                        button.backgroundColor = .systemBlue
                        return button
                    } (), ref: &blueButton),
                    Flex(width: 0, view: {
                        let button = UIButton(type: .system)
                        button.backgroundColor = .systemPink
                        return button
                    } (), ref: &pinkButton),
                ])
            ]),
            Flex(1),
            Flex(view: {
                let button = UIButton(type: .system)
                button.setTitle("Sign in", for: .normal)
                return button
            } ()),
            Spacer(80),
        ])
        
        flex.setRootView(view)
        
        // draw the layout to debug
        flex.debugDraw()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.view.animateUpdateConstraints(duration: 0.3) {
                otherLoginWaysLayout?.height = 44
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.view.animateUpdateConstraints(duration: 0.3) {
                blueButton?.flex = 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.view.animateUpdateConstraints(duration: 0.3) {
                pinkButton?.width = 44
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

