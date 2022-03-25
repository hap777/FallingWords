//
//  Extensions.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/25/22.
//

import UIKit

extension UIButton {
    func setupPrimary(color: UIColor = .systemRed) {
        clipsToBounds = true
        layer.cornerRadius = 8
        backgroundColor = color
        titleLabel?.textColor = .white
        tintColor = .white
    }

    func setupSecondary(color: UIColor = .systemRed) {
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        backgroundColor = .white
        titleLabel?.textColor = color
        tintColor = color
    }
}
