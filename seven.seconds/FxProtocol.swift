//
//  Fx.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 06.02.2023.
//

import Foundation
import UIKit
import AVFAudio

protocol FxProtocol {
    func addParallaxToView(vw: UIView)
    func setBackgroundImageView(bounds: CGRect, center: CGPoint) -> UIImageView
    func setupAudioPlayer(withFile file: String?, type: String?) -> AVAudioPlayer?
    func renderBlur(viewTarget: UIView, isDark: Bool)
}
