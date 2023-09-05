//
//  UIManager.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 05.09.2023.
//

import UIKit
import AVFoundation
import GameKit

class UIManager {
    static func setupUIElements(_ uiElements: [UILabel]) {
        uiElements.forEach { $0.textColor = UIColor.white }
    }
    
    static func setupButtonImages(button: UIButton) {
        let imageNormal = UIImage(named: "button_normal.png")
        button.setImage(imageNormal, for: .normal)
        let imageSelected = UIImage(named: "button_pressed.png")
        button.setImage(imageSelected, for: .highlighted)
    }
    
    static func updateLabel(_ label: UILabel, text: String, color: UIColor) {
        label.text = text
        label.textColor = color
    }
}
