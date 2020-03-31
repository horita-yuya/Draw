import PencilKit

@available(iOS 13, *)
extension PKEraserTool.EraserType {
    var toEraserType: EraserTool.EraserType {
        switch self {
        case .bitmap: return .bitmap
        case .vector: return .vector
        }
    }
}
