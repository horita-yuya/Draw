import UIKit

final class EraserContext {
    var eraserLayer: CAShapeLayer?
    var points: [CGPoint] = []
    
    func reset() {
        eraserLayer = nil
        points = []
    }
}
