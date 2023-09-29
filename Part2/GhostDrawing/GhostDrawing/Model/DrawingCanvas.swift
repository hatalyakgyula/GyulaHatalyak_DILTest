//
//  DrawingCanvas.swift
//  GhostDrawing
//
//  Created by Gyula Hatalyak on 2023. 09. 11..
//

import Foundation
import CoreGraphics
import UIKit
import Combine

// To avoid data race reading and writing of canvas is done on an actor. We assume the main thread is not overloaded.
class DrawingCanvas: ObservableObject {

    @Published var cgImage: CGImage? // every change on the canvas is published by this property
    
    private var context: CGContext? // the context (canvas) to draw the lines on
    private var pointTransform: CGAffineTransform! // to convert SwiftUI coordinates to core graphic coordinates
    
    @MainActor
    func createCanvas(pixelSize: CGSize, bgColor: CGColor, lineWidth: CGFloat) {
        print("creating canvas for pixelSize: \(pixelSize)")
        let pixelWidth: Int = Int(pixelSize.width)
        let pixelHeight: Int = Int(pixelSize.height)
        
        context = CGContext(data: nil,
                            width: pixelWidth,
                            height: pixelHeight,
                            bitsPerComponent: 8,
                            bytesPerRow: pixelWidth * 4,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context!.setFillColor(bgColor)
        context!.setLineWidth(lineWidth)
        
        pointTransform = CGAffineTransformConcat(CGAffineTransform(scaleX: 1, y: -1), CGAffineTransform(translationX: 0, y: pixelSize.height))
        
        clear()
    }
    
    @MainActor
    private func publishChanges() {
        //   The CGImage object returned by makeImage() function is created by a copy operation.
        //   Subsequent changes to the bitmap graphics context do not affect the contents of the returned image.
        //   In some cases the copy operation actually follows copy-on-write semantics,
        //   so that the actual physical copy of the bits occur only if the underlying data in the bitmap graphics context is modified.
        cgImage = context?.makeImage()!
    }
        
    // accepts points in SwiftUI coordinate space in pixels
    @MainActor
    func addLine(startPoint: CGPoint, endPoint: CGPoint, color: CGColor) {
        context?.move(to: startPoint.applying(pointTransform))
        context?.setStrokeColor(color)
        context?.addLine(to: endPoint.applying(pointTransform))
        context?.drawPath(using: .stroke)
        publishChanges()
    }
    
    @MainActor
    func clear() {
        context?.fill(CGRect(x: 0, y: 0, width: context!.width, height: context!.height))
        publishChanges()
    }
}
