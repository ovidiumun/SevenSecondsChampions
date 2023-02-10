//
//  fx.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 06.02.2023.
//

import Foundation
import UIKit
import AVFAudio

public class Fx: FxProtocol {
    
    public func addParallaxToView(vw: UIView) {
        let amount = 40

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    public func setBackgroundImageView(bounds: CGRect, center: CGPoint) -> UIImageView {
        var bounds: CGRect = bounds
        bounds.size.width += 0
        bounds.size.height += 0
        
        let background = UIImage(named: "background.jpeg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = center
        
        return imageView
    }
    
    public func setupAudioPlayer(withFile file: String?, type: String?) -> AVAudioPlayer? {
        let path = Bundle.main.path(forResource: file, ofType: type)
        let url = URL(fileURLWithPath: path ?? "")

        var _: Error?

        var audioPlayer: AVAudioPlayer? = nil
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
        }

        return audioPlayer
    }
    
    public func renderBlur(viewTarget: UIView, isDark: Bool) {
        var blurEffect: UIBlurEffect? = nil
        
        if #available(iOS 10.0, *) {
            if (isDark) {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            } else {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            }
        } else {
            if (isDark) {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            } else {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            }
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewTarget.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewTarget.addSubview(blurEffectView)
    }
}
