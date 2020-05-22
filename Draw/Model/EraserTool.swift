import PencilKit

public struct EraserTool: DrawingTool {
    public enum EraserType {
        case vector
        case bitmap
        
        @available(iOS 13, *)
        var toEraserType: PKEraserTool.EraserType {
            switch self {
            case .vector: return .vector
            case .bitmap: return .bitmap
            }
        }
    }
    
    public var eraserType: EraserType
    public var size: CGFloat
    
    public init(_ eraserType: EraserType, size: CGFloat = 40) {
        self.eraserType = eraserType
        self.size = size
    }
    
    @available(iOS 13, *)
    public func toPKTool() -> PKTool {
        PKEraserTool(eraserType.toEraserType)
    }
}
