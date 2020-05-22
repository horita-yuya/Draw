import PencilKit

public struct LassoTool: DrawingTool {
    public init() {}
    
    @available(iOS 13, *)
    public func toPKTool() -> PKTool {
        PKLassoTool()
    }
}
