# Milo's Wheel: Flex layout 

[![CI Status](https://img.shields.io/travis/milomai/MLWFlexLayout.svg?style=flat)](https://travis-ci.org/milomai/MLWFlexLayout)
[![Version](https://img.shields.io/cocoapods/v/MLWFlexLayout.svg?style=flat)](https://cocoapods.org/pods/MLWFlexLayout)
[![License](https://img.shields.io/cocoapods/l/MLWFlexLayout.svg?style=flat)](https://cocoapods.org/pods/MLWFlexLayout)
[![Platform](https://img.shields.io/cocoapods/p/MLWFlexLayout.svg?style=flat)](https://cocoapods.org/pods/MLWFlexLayout)

A flex layout system with declarative UI for iOS. Just like Flutter & SwiftUI. No hod reload support

一个 iOS 上的声明式 Flex 布局框架。适用于无法使用 SwiftUI，又想使用声明式 UI 的项目。

## TODOS

- [x] Dynamic change size
- [ ] Scrollview as root

## Usage
```swift
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
        Row(width: 260, mainAlignment: .spaceBetween, [
            Flex(width: 44, height: 44, view: {
                let button = UIButton(type: .system)
                button.backgroundColor = .cyan
                return button
            } ()),
            Flex(width: 44, height: 44, view: {
                let button = UIButton(type: .system)
                button.backgroundColor = .systemBlue
                return button
            } ()),
            Flex(width: 44, height: 44, view: {
                let button = UIButton(type: .system)
                button.backgroundColor = .systemPink
                return button
            } ()),
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
```

### Change Size At Runtime 动态改变大小

Limit: can not set width or height to a layout which have a flex value
限制：使用 flex 设置大小的 layout 不能在之后改成使用固定大小。

```swift
var layoutRef: Flex?

Column([
    Flex(width :0, height:44 ref: &layoutRef),
])

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    self.view.animateUpdateConstraints(duration: 0.3) {
        layoutRef?.width = 44
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

copy 'Flex.swift' & 'Helper.swift' to your project

## Author

Milo Mai, milo.mai.cn@gmail.com

## License

MLWFlexLayout is available under the MIT license. See the LICENSE file for more info.
