import UIKit
import func AVFoundation.AVMakeRect
import MetalKit

private final class ImageLayer: CALayer {}

final class InnerCanvasView: UIImageView {
    var canvasImageView: CanvasImageViewProtocol? {
        didSet {
            guard let imageView = canvasImageView else { return }
            oldValue?.removeFromSuperview()
            addSubview(imageView)
            imageView.confirmSelected = { [weak self] in
                self?.extractImageLayerFromCanvasImageView()
            }
        }
    }
    
    var tool: DrawingTool = InkingTool(inkType: .pen, color: .black) {
        didSet {
            eraserContext.reset()
            lassoContext.reset()
        }
    }
    
    private var inkingContexts: [InkingContext] = []
    private let eraserContext: EraserContext = .init()
    private let lassoContext: LassoContext = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canvasImageView != nil, let location = touches.first?.location(in: self) {
            canvasImageView?.center = location
            
        } else if tool is InkingTool {
            inkingBegan(touches: touches)
            
        } else if tool is EraserTool {
            eraserBegan(touches: touches)
            
        } else if tool is LassoTool {
            lassoBegan(touches: touches)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canvasImageView != nil, let location = touches.first?.location(in: self) {
            canvasImageView?.center = location
            
        } else if tool is InkingTool {
            inkingMoved(touches: touches, event: event)
            
        } else if tool is EraserTool {
            eraserMoved(touches: touches, event: event)
            
        } else if tool is LassoTool {
            lassoMoved(touches: touches, event: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canvasImageView != nil, let location = touches.first?.location(in: self) {
            canvasImageView?.center = location
            
        } else if tool is InkingTool {
            inkingEnded(touches: touches, event: event)
            
        } else if tool is EraserTool {
            eraserEnded(touches: touches, event: event)
            
        } else if tool is LassoTool {
            lassoEnded(touches: touches, event: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.center = center
    }
    
    func extractImageLayerFromCanvasImageView() {
        guard let imageView = canvasImageView, let image = imageView.imageView.image else { return }
        
        let layer = ImageLayer()
        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: imageView.imageView.frame)
        
        let frame = CGRect(
            x: imageView.frame.origin.x + imageRect.origin.x,
            y: imageView.frame.origin.y + imageRect.origin.y,
            width: imageRect.width,
            height: imageRect.height
        )
        
        layer.frame = frame
        layer.transform = imageView.layer.transform
        layer.contents = image.cgImage
        imageView.removeFromSuperview()
        self.layer.addSublayer(layer)
        self.canvasImageView = nil
        registerUndoImage(imageLayer: layer)
        
        let context = InkingContext()
        context.imageLayer = layer
        context.points = layer.frame.convertToPoints()
        inkingContexts.append(context)
    }
    
    func undo() {
        undoManager?.undo()
    }
    
    func redo() {
        undoManager?.redo()
    }
}

private extension InnerCanvasView {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        layer.backgroundColor = UIColor.white.cgColor
    }
    
    func registerUndoImage(imageLayer: ImageLayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            imageLayer.removeFromSuperlayer()
            self?.registerRedoImage(imageLayer: imageLayer)
        }
    }
    
    func registerRedoImage(imageLayer: ImageLayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] target in
            target.layer.addSublayer(imageLayer)
            self?.registerUndoImage(imageLayer: imageLayer)
        }
    }
}

// MARK: Drawing

private extension InnerCanvasView {
    func inkingBegan(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        inkingContexts.append(.init())

        let pathLayer = DrawingLayer()
        inkingContexts.last?.pathLayer = pathLayer
        inkingContexts.last?.pathLayer?.use(tool: tool)
        inkingContexts.last?.points = [touch.location(in: self)]
        
        layer.addSublayer(pathLayer)
    }

    func inkingMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touches = event?.coalescedTouches(for: touch) ?? [touch]
        inkingContexts.last?.points += touches.map { $0.location(in: self) }

        let predictedPoints = event?.predictedTouches(for: touch)?.map { $0.location(in: self) } ?? []
        
        inkingContexts.last?.pathLayer?.path = UIBezierPath.interpolate(points: inkingContexts.last!.points + predictedPoints).cgPath
    }

    func inkingEnded(touches: Set<UITouch>, event: UIEvent?) {
        if let inkingLayer = inkingContexts.last?.pathLayer {
            inkingLayer.path = UIBezierPath.interpolate(points: inkingContexts.last!.points).cgPath
            registerUndoInking(inkingLayer: inkingLayer)
        }
    }
    
    func registerUndoInking(inkingLayer: CAShapeLayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            inkingLayer.removeFromSuperlayer()
            self?.registerRedoInking(inkingLayer: inkingLayer)
        }
    }
    
    func registerRedoInking(inkingLayer: CAShapeLayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] target in
            target.layer.addSublayer(inkingLayer)
            self?.registerUndoInking(inkingLayer: inkingLayer)
        }
    }
}

// MARK: Eraser

extension InnerCanvasView {
    func eraserBegan(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let eraserLayer = EraserLayer()
        eraserContext.eraserLayer = eraserLayer
        eraserLayer.position = touch.location(in: self)
        
        layer.addSublayer(eraserLayer)
    }
    
    func eraserMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        eraserContext.eraserLayer?.position = location
        CATransaction.commit()
        
        let rect = CGRect(
            x: location.x - 20,
            y: location.y - 20,
            width: 40,
            height: 40
        )

        for context in inkingContexts {
            if context.points.first(where: { rect.contains($0) }) != nil {
                guard let layer = context.pathLayer, layer.superlayer != nil else { continue }
                
                layer.removeFromSuperlayer()
                registerUndoEraser(inkingLayer: layer)
            }
            
            if let imageLayer = context.imageLayer,
                imageLayer.superlayer != nil,
                imageLayer.frame.intersects(rect) {
                imageLayer.removeFromSuperlayer()
                registerUndoEraser(inkingLayer: imageLayer)
            }
        }
    }
    
    func eraserEnded(touches: Set<UITouch>, event: UIEvent?) {
        eraserContext.reset()
    }
    
    func registerUndoEraser(inkingLayer: CALayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] target in
            target.layer.addSublayer(inkingLayer)
            self?.registerRedoEraser(inkingLayer: inkingLayer)
        }
    }
    
    func registerRedoEraser(inkingLayer: CALayer) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            inkingLayer.removeFromSuperlayer()
            self?.registerUndoEraser(inkingLayer: inkingLayer)
        }
    }
}

// MARK: Lasso

extension InnerCanvasView {
    func lassoBegan(touches: Set<UITouch>) {
        guard let location = touches.first?.location(in: self) else { return }
        
        switch lassoContext.mode {
        case .search:
            let lassoLayer = CAShapeLayer()
            lassoLayer.use(tool: tool)
            layer.addSublayer(lassoLayer)

            lassoContext.lassoLayer = lassoLayer
            lassoContext.points = [location]
            
        case .move:
            if lassoContext.lassoLayer?.path?.boundingBoxOfPath.contains(location) ?? false {
                lassoContext.moveCurrentPotision = location
            }
        }
    }

    func lassoMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        switch lassoContext.mode {
        case .search:
            let touches = event?.coalescedTouches(for: touch) ?? [touch]
            lassoContext.points += touches.map { $0.location(in: self) }
            
            let predictedPoints = event?.predictedTouches(for: touch)?.map { $0.location(in: self) } ?? []
            lassoContext.lassoLayer?.path = UIBezierPath.interpolate(points: lassoContext.points + predictedPoints).cgPath

        case .move:
            guard let lastLocation = lassoContext.moveCurrentPotision else { return }

            let location = touch.location(in: self)
            let dx = location.x - lastLocation.x
            let dy = location.y - lastLocation.y

            lassoContext.moveCurrentPotision = location
            lassoContext.dx += dx
            lassoContext.dy += dy

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lassoContext.lassoEnclosedInkingContexts.forEach {
                $0.pathLayer?.frame.origin.x += dx
                $0.pathLayer?.frame.origin.y += dy
                $0.imageLayer?.frame.origin.x += dx
                $0.imageLayer?.frame.origin.y += dy
            }
            lassoContext.lassoLayer?.frame.origin.x += dx
            lassoContext.lassoLayer?.frame.origin.y += dy
            CATransaction.commit()
        }
    }

    func lassoEnded(touches: Set<UITouch>, event: UIEvent?) {
        switch lassoContext.mode {
        case .search:
            let path = UIBezierPath.interpolate(points: lassoContext.points, closed: true).cgPath
            lassoContext.lassoLayer?.path = path
            lassoContext.points = []
            
            let targetContexts = inkingContexts.filter {
                $0.points.first(where: { path.contains($0) }) != nil
            }
            
            lassoContext.lassoEnclosedInkingContexts = targetContexts
            
            if lassoContext.lassoEnclosedInkingContexts.isEmpty {
                lassoContext.lassoLayer?.removeFromSuperlayer()
                
            } else {
                lassoContext.mode = .move
                
                let animation = CABasicAnimation(keyPath: "lineDashPhase")
                animation.fromValue = 16
                animation.toValue = 0
                animation.duration = 0.2
                animation.repeatCount = .infinity
                lassoContext.lassoLayer?.add(animation, forKey: nil)
            }
        
        case .move:
            lassoContext.lassoEnclosedInkingContexts.forEach {
                for i in 0..<$0.points.count {
                    $0.points[i].x += lassoContext.dx
                    $0.points[i].y += lassoContext.dy
                }
            }
            
            registerUndoLasso(
                enclosedInkingContexts: lassoContext.lassoEnclosedInkingContexts,
                dx: lassoContext.dx,
                dy: lassoContext.dy
            )
            lassoContext.reset()
        }
    }
    
    func registerUndoLasso(enclosedInkingContexts: [InkingContext], dx: CGFloat, dy: CGFloat) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            enclosedInkingContexts.forEach {
                for i in 0..<$0.points.count {
                    $0.points[i].x -= dx
                    $0.points[i].y -= dy
                }
                
                $0.pathLayer?.frame.origin.x -= dx
                $0.pathLayer?.frame.origin.y -= dy
                $0.imageLayer?.frame.origin.x -= dx
                $0.imageLayer?.frame.origin.y -= dy
            }
            self?.registerRedoLasso(enclosedInkingContexts: enclosedInkingContexts, dx: dx, dy: dy)
        }
    }
    
    func registerRedoLasso(enclosedInkingContexts: [InkingContext], dx: CGFloat, dy: CGFloat) {
        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            enclosedInkingContexts.forEach {
                for i in 0..<$0.points.count {
                    $0.points[i].x += dx
                    $0.points[i].y += dy
                }
                
                $0.pathLayer?.frame.origin.x += dx
                $0.pathLayer?.frame.origin.y += dy
                $0.imageLayer?.frame.origin.x += dx
                $0.imageLayer?.frame.origin.y += dy
            }
            
            self?.registerUndoLasso(enclosedInkingContexts: enclosedInkingContexts, dx: dx, dy: dy)
        }
    }
}
