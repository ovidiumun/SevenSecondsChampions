//
//  Sparks.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 06.02.2023.
//

import Foundation
import UIKit

protocol SparksProtocol {
    func createSmallSparks(emitterLayerGlobal: inout CAEmitterLayer?, emitterCellGlobal: CAEmitterCell, view: UIView!)
    func createSparks(emitterLayer: inout CAEmitterLayer?, emitterCell: CAEmitterCell, view: UIView!, button: UIButton)
}
