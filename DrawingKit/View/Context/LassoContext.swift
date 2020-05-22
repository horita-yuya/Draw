import UIKit

final class LassoContext {
    enum Mode {
        case search
        case move
    }
    
    var mode: Mode = .search
    var lassoLayer: CAShapeLayer?
    var lassoEnclosedInkingContexts: [InkingContext] = []
    var points: [CGPoint] = []

    var moveCurrentPotision: CGPoint?
    
    var dx: CGFloat = 0
    var dy: CGFloat = 0

    func reset() {
        lassoLayer?.removeAllAnimations()
        lassoLayer?.removeFromSuperlayer()
        lassoLayer = nil
        lassoEnclosedInkingContexts = []
        points = []
        mode = .search

        moveCurrentPotision = nil
        
        dx = 0
        dy = 0
    }
}
