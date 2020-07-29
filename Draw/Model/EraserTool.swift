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
    public var canEraseImage: Bool
    
    public init(_ eraserType: EraserType, size: CGFloat = 40, canEraseImage: Bool = true) {
        self.eraserType = eraserType
        self.size = size
        self.canEraseImage = canEraseImage
    }
    
    @available(iOS 13, *)
    public func toPKTool() -> PKTool {
        PKEraserTool(eraserType.toEraserType)
    }
}
