import UIKit.UIColor
import PencilKit

public struct InkingTool: DrawingTool {
    public enum InkType: String {
        case pencil
        case pen
        case marker
        
        @available(iOS 13, *)
        var toPKInkType: PKInkingTool.InkType {
            switch self {
            case .pencil: return .pencil
            case .pen: return .pen
            case .marker: return .marker
            }
        }
    }
    
    public var color: UIColor
    public var width: CGFloat
    public var inkType: InkType
    
    public init(inkType: InkType, color: UIColor, width: CGFloat? = nil) {
        self.inkType = inkType
        self.color = color
        self.width = width ?? 4
    }
    
    @available(iOS 13, *)
    public func toPKTool() -> PKTool {
        PKInkingTool(inkType.toPKInkType, color: color, width: width)
    }
}
