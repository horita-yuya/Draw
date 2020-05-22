import UIKit

final class DrawingLayer: CAShapeLayer {}

final class InkingContext {
    var points: [CGPoint] = []
    var path: UIBezierPath?
    var pathLayer: DrawingLayer?
    var imageLayer: CALayer?
    
    func reset() {
        points = []
        path = nil
        pathLayer = nil
        imageLayer = nil
    }
}
