import UIKit

enum CanvasEvent {
    case drawingLine(lineLayer: CALayer)
    case eraser(targetLayers: [CALayer], eraserLayer: CALayer)
    case lasso(targetLayers: [CALayer], dx: CGFloat, dy: CGFloat)
}
