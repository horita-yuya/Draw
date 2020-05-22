import UIKit

final class EraserContext {
    var eraserLayer: EraserLayer?
    
    func reset() {
        eraserLayer?.removeFromSuperlayer()
        eraserLayer = nil
    }
}

final class EraserLayer: CALayer {
    override init() {
        super.init()
        configure()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        backgroundColor = UIColor.clear.cgColor
        borderColor = UIColor.black.cgColor
        borderWidth = 3
        cornerRadius = 20
        bounds = .init(x: 0, y: 0, width: 40, height: 40)
    }
}
