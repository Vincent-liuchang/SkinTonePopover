//
//  ReactionCell.swift
//  testSpace
//
//  Created by Vincent Liu on 2021/11/5.
//

import UIKit

class ReactionCell: UICollectionViewCell {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.text = "A"
            } else {
                label.text = "B"
            }
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = isSelected ? "A" : "B"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        addConstraints()
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 5
        selectedBackgroundView = view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        var customConstraints = [NSLayoutConstraint]()
        customConstraints.append(label.widthAnchor.constraint(equalTo: contentView.widthAnchor))
        customConstraints.append(label.heightAnchor.constraint(equalTo: contentView.heightAnchor))
        customConstraints.append(label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        customConstraints.append(label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        customConstraints.append(contentView.heightAnchor.constraint(equalToConstant: 40))
        customConstraints.append(contentView.widthAnchor.constraint(equalToConstant: 40))
        NSLayoutConstraint.activate(customConstraints)
    }
}
