//
//  Sparks.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 06.02.2023.
//

import Foundation
import UIKit
import SpriteKit

class Sparks: SparksProtocol {
    public func createSmallSparks( emitterLayerGlobal: inout CAEmitterLayer?, emitterCellGlobal: CAEmitterCell, view: UIView!) {
        guard let image = UIImage(named: "spark.png")?.cgImage else { fatalError("Failed loading image.") }
        
        emitterLayerGlobal = CAEmitterLayer(layer: image)
        emitterLayerGlobal?.name = "Emitter"
        
        emitterLayerGlobal?.emitterPosition.x = view.frame.midX - 10
        emitterLayerGlobal?.emitterPosition.y = -50
        
        let color = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1);
        emitterCellGlobal.color = color
        emitterCellGlobal.name = "cell"
        emitterCellGlobal.birthRate = 120
        emitterCellGlobal.lifetime = 20
        emitterCellGlobal.velocity = 42

        emitterCellGlobal.scale = 0.05
        emitterCellGlobal.scaleRange = 0.1
        emitterCellGlobal.emissionRange = CGFloat.pi * 2.0
        emitterCellGlobal.contents = image
        
        emitterLayerGlobal?.emitterCells = [emitterCellGlobal]
        view.layer.addSublayer(emitterLayerGlobal!)
    }
    
    public func createSparks( emitterLayer: inout CAEmitterLayer?, emitterCell: CAEmitterCell, view: UIView!, button: UIButton) {
        guard let image = UIImage(named: "spark.png")?.cgImage else { fatalError("Failed loading image.") }
        
        emitterLayer = CAEmitterLayer(layer: image)
        emitterLayer?.name = "Emitter"
        
        emitterLayer?.emitterPosition.x = (view?.frame.maxX)! -
            button.frame.height / 2 - 10
        emitterLayer?.emitterPosition.y = view.frame.midY +
            button.frame.height / 2 - 40
        
         let newColor = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1);
         emitterCell.color = newColor
         emitterCell.name = "cell"
         emitterCell.birthRate = 20
         emitterCell.lifetime = 16
         emitterCell.velocity = 22
         
         emitterCell.scale = 0.18
         emitterCell.scaleRange = 0.2
         emitterCell.emissionLongitude = .pi / 2.0
         emitterCell.emissionRange = CGFloat.pi / 4.0
         emitterCell.contents = image
        
        emitterLayer?.emitterCells = [emitterCell]
        view.layer.addSublayer(emitterLayer!)
    }
    
    /*public func addSparks(skView: SKView, scene: SKScene, emitterNode: SKEmitterNode, frame:CGRect, size: CGSize, button: UIButton) {
        skView = SKView(frame: view.frame)
        scene = SKScene(size: view.frame.size)
        
        skView.backgroundColor = .clear
        scene.backgroundColor = .clear
        
        skView.presentScene(scene)
        skView.isUserInteractionEnabled = false
        
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.addChild(emitterNode)
        
        //emitterNode.position.x = scene.frame.maxX - buttonPushIt.frame.height - 0
        //emitterNode.position.y = scene.frame.midY
        
        emitterNode.position.x = scene.frame.maxX - button.frame.height / 2 - 20
        emitterNode.position.y = scene.frame.midY - button.frame.width / 2 + 20
        
        skView.tag = 4
        //view.addSubview(skView) ??? parametrize
        //self.view.viewWithTag(4)?.isHidden = true ??? parametrize
    }*/
}
