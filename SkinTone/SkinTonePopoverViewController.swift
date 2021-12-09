//
//  SkinTonePopoverViewController.swift
//  skinTone
//
//  Created by ChangLiu on 2021/12/7.
//
import UIKit

class SkinToneCellItem {
    var label: String
    var isSelected: Bool
    
    init (label: String, isSelected: Bool) {
        self.label = label
        self.isSelected = isSelected
    }
}

protocol SkinTonePopoverViewControllerDelegate: AnyObject {
    func skinTonePopoverViewController(_ skinTonePopoverViewController: UIViewController & SkinTonePopoverViewControllerProtocol, didSelectItem menuItem: SkinToneCellItem)
    func skinTonePopoverViewControllerWillDismiss(_ skinTonePopoverViewController: UIViewController & SkinTonePopoverViewControllerProtocol)
}

protocol SkinTonePopoverViewControllerProtocol: UIPopoverPresentationControllerDelegate {
    var items: [SkinToneCellItem] { get set }
    var delegate: SkinTonePopoverViewControllerDelegate? { get set }
    var panView: UIView? { get set }
}

class SkinTonePopoverViewController: UIViewController, SkinTonePopoverViewControllerProtocol {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.minimumInteritemSpacing = 10
        collectionViewLayout.estimatedItemSize = CGSize(width: 40, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "collectionView"
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.isHidden = false
        view.register(ReactionCell.self, forCellWithReuseIdentifier: "reactionCell")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard items.count > 1 else { return }
        collectionView.selectItem(at: IndexPath(row: selectedIndexWhenInit, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.skinTonePopoverViewControllerWillDismiss(self)
    }
    
    func applyTheme() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        popoverPresentationController?.backgroundColor = .systemBackground
    }
    
    weak var delegate: SkinTonePopoverViewControllerDelegate?
    
    var items: [SkinToneCellItem] = [] {
        didSet {
            selectedIndexWhenInit = items.firstIndex(where: { $0.isSelected == true }) ?? 0
            collectionView.reloadData()
        }
    }
    
    var selectedIndexWhenInit: Int = 0
    lazy var finalIndex = selectedIndexWhenInit
    var panView: UIView?
    
    func addConstraints() {
        var customConstraints: [NSLayoutConstraint] = []
        customConstraints.append(collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        customConstraints.append(collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        customConstraints.append(collectionView.heightAnchor.constraint(equalToConstant: 40))
        customConstraints.append(collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10))
        customConstraints.append(collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10))
        NSLayoutConstraint.activate(customConstraints)
    }
    
    func onPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let touchStart = sender.location(in: panView)
            print("begin \(touchStart)")
        case .changed:
            let distance = sender.translation(in: panView)
            let currentIndex = items.firstIndex(where: { $0.isSelected == true }) ?? 0
            finalIndex = (Int(distance.x / 32) + selectedIndexWhenInit) % items.count
            if finalIndex < 0 { finalIndex += items.count }
            if finalIndex != currentIndex {
                scrollToItem(index: finalIndex)
            }
        case .ended:
            guard finalIndex != selectedIndexWhenInit else { return }
            print("end")
            delegate?.skinTonePopoverViewController(self, didSelectItem: items[finalIndex])
        default: break
        }
    }
    
    private func scrollToItem(index: Int) {
        guard items.count > index else { return }
        items.first(where: { $0.isSelected == true })?.isSelected = false
        items[index].isSelected = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension SkinTonePopoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reactionCell", for: indexPath) as? ReactionCell ?? ReactionCell(frame: .zero)
        cell.isSelected = items[indexPath.row].isSelected
        return cell
    }
}

extension SkinTonePopoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}

extension SkinTonePopoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        print("select")
        delegate?.skinTonePopoverViewController(self, didSelectItem: items[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        items[indexPath.row].isSelected = false
    }
}
