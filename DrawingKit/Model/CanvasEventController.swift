import UIKit

final class CanvasEventController {
    private var canvasEvents: [CanvasEvent] = []
    private var redoEvents: [CanvasEvent] = []
    
    weak var targetView: UIView?
    
    func pushDrawingLineEvent(lineLayer: CALayer) {
        redoEvents = []
        canvasEvents.append(.drawingLine(lineLayer: lineLayer))
    }
    
    func pushEraserEvent(targetLayers: [CALayer], eraserLayer: CALayer) {
        redoEvents = []
        canvasEvents.append(.eraser(targetLayers: targetLayers, eraserLayer: eraserLayer))
    }
    
    func pushLassoEvent(context: LassoContext) {
        redoEvents = []
        canvasEvents.append(.lasso(targetLayers: context.lassoEnclosedLayers, dx: context.dx, dy: context.dy))
    }
    
    func undo() {
        guard let event = canvasEvents.popLast() else { return }
        redoEvents.append(event)
        
        switch event {
        case .drawingLine(let lineLayer):
            lineLayer.removeFromSuperlayer()
            
        case .eraser(_, let eraserLayer):
            eraserLayer.removeFromSuperlayer()
            
        case .lasso(let targetLayers, let dx, let dy):
            targetLayers.forEach {
                $0.frame.origin.x -= dx
                $0.frame.origin.y -= dy
            }
        }
    }
    
    func redo() {
        guard let event = redoEvents.popLast() else { return }
        canvasEvents.append(event)
        
        switch event {
        case .drawingLine(let lineLayer):
            targetView?.layer.addSublayer(lineLayer)
            
        case .eraser(let targetLayers, let eraserLayer):
            targetLayers.forEach { $0.addSublayer(eraserLayer) }
            
        case .lasso(let targetLayers, let dx, let dy):
            targetLayers.forEach {
                $0.frame.origin.x += dx
                $0.frame.origin.y += dy
            }
        }
    }
}
