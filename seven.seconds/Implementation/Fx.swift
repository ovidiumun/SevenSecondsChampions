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
        
        let background = UIImage(named: "swift-og.png")
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
    
    public func rotateButton(_ duration: Int, button: UIButton) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = NSNumber(value: 0)
        rotation.toValue = NSNumber(value: (360 * Double.pi) / 180)
        rotation.duration = CFTimeInterval(duration)
        rotation.repeatCount = .infinity
        button.layer.add(rotation, forKey: "360")
    }
    
    /*func infiniteScroll(duration: CGFloat) {
        let backgroundImage = UIImage(named: "swift-og.png")!
        let backgroundPattern = UIColor(patternImage: backgroundImage)
        
        let background = CALayer()
        background.backgroundColor = backgroundPattern.cgColor
        background.transform = CATransform3DMakeScale(1, -1, 1)
        background.anchorPoint = CGPoint(x: 0, y: 1)
        background.name = "background"
        
        let viewSize = self.view.layer.bounds.size
        background.frame = CGRect(x: 0, y: 0, width: viewSize.width, height: backgroundImage.size.height + viewSize.height)
        view.layer.insertSublayer(background, at: 0)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: -backgroundImage.size.height)
        
        animation = CABasicAnimation(keyPath: "position")
        guard let animation = self.animation else { return }
        
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fromValue = NSValue(cgPoint: endPoint)
        animation.toValue = NSValue(cgPoint: startPoint)
        animation.repeatCount = .greatestFiniteMagnitude
        animation.duration = duration
        background.add(animation, forKey: "position")
    }*/
    
    /*public func createFire(fireEmitter: inout CAEmitterLayer?, view: UIView) {
        fireEmitter = CAEmitterLayer()
        fireEmitter?.name = "fire"

        fireEmitter?.emitterPosition.x = view.frame.midX
        fireEmitter?.emitterPosition.y = view.frame.maxY + 100
        
        fireEmitter?.emitterSize = CGSize(width: view.frame.maxX / 1.5, height: 10);
        fireEmitter?.renderMode = CAEmitterLayerRenderMode.additive;
        fireEmitter?.emitterShape = CAEmitterLayerEmitterShape.line
        fireEmitter?.emitterCells = [createFireCell()];
        
        self.view.layer.addSublayer(fireEmitter!)
    }*/
    
    public func createFireCell() -> CAEmitterCell {
        let fire = CAEmitterCell();
        fire.alphaSpeed = -0.3
        fire.birthRate = 600;
        fire.lifetime = 60.0;
        fire.lifetimeRange = 0.5
        fire.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.6).cgColor
        fire.contents = UIImage(named: "fire")?.cgImage
        fire.emissionLongitude = CGFloat(Double.pi);
        fire.velocity = 80;
        fire.velocityRange = 5;
        fire.emissionRange = 0.5;
        fire.yAcceleration = -200;
        fire.scaleSpeed = 0.3;
        
        return fire
    }
}
