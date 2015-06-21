//
//  ShutterLayer.swift
//  Shutter
//
//  Created by Olivier Lesnicki on 20/06/2015.
//  Copyright (c) 2015 LEMOTIF. All rights reserved.
//

import Foundation
import QuartzCore
import AVFoundation

class ShutterLayer : CALayer {
    
    init(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        
        super.init()
        
        self.opacity = 0
        
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.beginTime = AVCoreAnimationBeginTimeAtZero + beginTime
        animation.duration = duration
        animation.values = [1, 0]
        animation.keyTimes = [0, 1]
        animation.removedOnCompletion = false
        animation.calculationMode = kCAAnimationDiscrete
        
        addAnimation(animation, forKey: "opacity")
        
    }
    
    func resize(size: CGSize) {}
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}