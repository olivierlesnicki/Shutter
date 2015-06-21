//
//  Shutter.swift
//  Shutter
//
//  Created by Olivier Lesnicki on 20/06/2015.
//  Copyright (c) 2015 LEMOTIF. All rights reserved.
//


import Foundation
import AVFoundation

class Shutter {
    
    var layers : [ShutterLayer]
    var path : String
    
    init(path: String, layers: [ShutterLayer]) {
        self.layers = layers
        self.path = path
    }
    
    func export(exportPath: String, callback: () -> (Void)) {
        
        let videoUrl = NSURL(fileURLWithPath: path)
        let video = AVURLAsset(URL: videoUrl, options: nil)
        let videoTracks = video.tracksWithMediaType(AVMediaTypeVideo)
        let videoTrack : AVAssetTrack = videoTracks[0] as! AVAssetTrack
        
        var composition = AVMutableComposition()
        var compositionTrackForVideo = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        compositionTrackForVideo.insertTimeRange(
            CMTimeRangeMake(kCMTimeZero, video.duration),
            ofTrack: videoTrack ,
            atTime: kCMTimeZero,
            error: nil
        )
        
        compositionTrackForVideo.preferredTransform = videoTrack.preferredTransform
        
        var size = compositionTrackForVideo.naturalSize
                
        var parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        var videoLayer = CALayer()
        videoLayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        var overlayLayer = CALayer()
        overlayLayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        for layer in layers {
            layer.resize(size)
            overlayLayer.addSublayer(layer)
        }
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        var videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            inLayer: parentLayer
        )
        
        var instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
        
        var layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        
        videoComposition.instructions = [instruction]
        
        if (NSFileManager.defaultManager().fileExistsAtPath(exportPath)) {
            NSFileManager.defaultManager().removeItemAtPath(exportPath, error: nil)
        }
        
        let exportURL = NSURL(fileURLWithPath: exportPath)
        
        var export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        export.videoComposition = videoComposition
        export.outputURL = exportURL
        export.outputFileType = AVFileTypeQuickTimeMovie
        export.shouldOptimizeForNetworkUse = true
        
        export.exportAsynchronouslyWithCompletionHandler({
            dispatch_async(dispatch_get_main_queue()) {
                callback()
            }
        })
        
    }
    
    
    
}