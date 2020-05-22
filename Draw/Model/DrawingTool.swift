import PencilKit

public protocol DrawingTool {
    @available(iOS 13, *)
    func toPKTool() -> PKTool
}
