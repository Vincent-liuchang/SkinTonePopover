//
//  ViewController.swift
//  SkinTone
//
//  Created by ChangLiu on 2021/12/7.
//

import UIKit

class ViewController: UIViewController {
    
    var popover : SkinTonePopoverViewController?
    let items = [SkinToneCellItem(label: "1", isSelected: false), SkinToneCellItem(label: "2", isSelected: true),  SkinToneCellItem(label: "3", isSelected: false),  SkinToneCellItem(label: "4", isSelected: false),  SkinToneCellItem(label: "5", isSelected: false)]
    
    private lazy var button: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "globe.asia.australia")
        return imageView
    }()
    
    private lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        gesture.allowableMovement = .greatestFiniteMagnitude
        gesture.delegate = self
        return gesture
    }()
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, !(popover?.isBeingPresented ?? false) {
            makePopover()
        }
    }
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        popover?.onPan(sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addSubview(button)
        button.addGestureRecognizer(longPressRecognizer)
        button.addGestureRecognizer(panGestureRecognizer)
        addConstraints()
        applyTheme()
        // Do any additional setup after loading the view.
    }
    
    private func addConstraints() {
        var customConstraints: [NSLayoutConstraint] = []
        customConstraints.append(button.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        customConstraints.append(button.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        customConstraints.append(button.widthAnchor.constraint(equalToConstant: 30))
        customConstraints.append(button.heightAnchor.constraint(equalToConstant: 30))
        NSLayoutConstraint.activate(customConstraints)
    }
    
    private func makePopover() {
        let skinTonePopoverViewController = SkinTonePopoverViewController()
        popover = skinTonePopoverViewController
        skinTonePopoverViewController.delegate = self
        skinTonePopoverViewController.modalPresentationStyle = .popover
        skinTonePopoverViewController.items = items
        let itemNumber = skinTonePopoverViewController.items.count
        skinTonePopoverViewController.preferredContentSize = CGSize(width: 50 * itemNumber + 10, height: 60)
        skinTonePopoverViewController.popoverPresentationController?.sourceView = button
        skinTonePopoverViewController.popoverPresentationController?.sourceRect = button.bounds
        skinTonePopoverViewController.popoverPresentationController?.permittedArrowDirections = [.down]
        skinTonePopoverViewController.popoverPresentationController?.delegate = self
        skinTonePopoverViewController.popoverPresentationController?.popoverBackgroundViewClass = PopoverBackgroundView.self
        skinTonePopoverViewController.panView = view
        present(skinTonePopoverViewController, animated: true)
    }
    
    private func applyTheme() {
        view.backgroundColor = .white
        button.tintColor = .blue
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

class PopoverBackgroundView: UIPopoverBackgroundView {
    private let maskPathLayer: CAShapeLayer
    private var offset: CGFloat = 8.0
    
    override init(frame: CGRect) {
        maskPathLayer = CAShapeLayer()
        maskPathLayer.fillColor = UIColor.systemBackground.cgColor
        super.init(frame: frame)
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.addSublayer(maskPathLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: CGRect(x: frame.midX + arrowOffset - 20, y: frame.maxY - 10, width: 40, height: 50), cornerRadius: 5)
        maskPathLayer.path = maskPath.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func arrowBase() -> CGFloat {
        return 0.0
    }
    
    override static func contentViewInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override static func arrowHeight() -> CGFloat {
        return 0
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return .down
        }
        set {
            print("arrowDirection: \(newValue)")
        }
    }
    
    override var arrowOffset: CGFloat {
        get {
            return offset
        }
        set {
            offset = newValue
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        return true
    }
}

extension ViewController: SkinTonePopoverViewControllerDelegate {
    func skinTonePopoverViewControllerWillDismiss(_ skinTonePopoverViewController: UIViewController & SkinTonePopoverViewControllerProtocol) {}
    
    func skinTonePopoverViewController(_ skinTonePopoverViewController: UIViewController & SkinTonePopoverViewControllerProtocol, didSelectItem menuItem: SkinToneCellItem) {
        items.first(where: { $0.label == menuItem.label })?.isSelected = true
    }
}
