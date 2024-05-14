import PencilKit

@available(iOS 13, *)
extension PKInkingTool.InkType {
    var toInkType: InkingTool.InkType {
        switch self {
        case .pen: return .pen
        case .pencil: return .pencil
        case .marker: return .marker
        default: return .pencil
        }
    }
}
