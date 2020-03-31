import UIKit

final class LassoContext {
    var lassoLayer: CAShapeLayer?
    var lassoClosed: Bool = false
    var lassoEnclosedLayers: [CALayer] = []
    var points: [CGPoint] = []

    var moveCurrentPotision: CGPoint?
    
    var dx: CGFloat = 0
    var dy: CGFloat = 0

    func reset() {
        lassoLayer?.removeAllAnimations()
        lassoLayer?.removeFromSuperlayer()
        lassoLayer = nil
        lassoClosed = false
        lassoEnclosedLayers = []
        points = []

        moveCurrentPotision = nil
        
        dx = 0
        dy = 0
    }
}
