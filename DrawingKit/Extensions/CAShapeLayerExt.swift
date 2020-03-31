import UIKit

extension CAShapeLayer {
    var movedBoundingBox: CGRect {
        let frame = self.frame
        let boundingBox = path?.boundingBoxOfPath ?? .zero

        return .init(
            x: frame.origin.x + boundingBox.origin.x,
            y: frame.origin.y + boundingBox.origin.y,
            width: boundingBox.width,
            height: boundingBox.height
        )
    }
    
    func use(tool: DrawingTool) {
        if let inkingTool = tool as? InkingTool {
            fillColor = UIColor.clear.cgColor
            strokeColor = inkingTool.color.cgColor
            lineWidth = inkingTool.width
            lineJoin = .round
            lineCap = .round

        } else if let eraserTool = tool as? EraserTool {
            fillColor = UIColor.clear.cgColor
            strokeColor = UIColor.white.cgColor
            lineWidth = eraserTool.size
            lineJoin = .round
            lineCap = .round

        } else if tool is LassoTool {
            fillColor = UIColor.clear.cgColor
            strokeColor = UIColor.black.cgColor
            lineWidth = 1
            lineJoin = .round
            lineCap = .round
            lineDashPattern = [8, 8]
        }
    }
}
