import UIKit
import func AVFoundation.AVMakeRect

private final class ImageLayer: CALayer {}
private final class EraserLayer: CAShapeLayer {}

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
            inkingContext.reset()
            eraserContext.reset()
            lassoContext.reset()
        }
    }
    
    private let eventController = CanvasEventController()
    private let inkingContext: InkingContext = .init()
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
        layer.contents = image.cgImage
        imageView.removeFromSuperview()
        self.layer.addSublayer(layer)
        self.eventController.pushDrawingLineEvent(lineLayer: layer)
        self.canvasImageView = nil
    }

    func captureBackground() -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let render = UIGraphicsImageRenderer(bounds: bounds, format: format)
        
        return render.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
    
    func undo() {
        eventController.undo()
    }
    
    func redo() {
        eventController.redo()
    }
}

private extension InnerCanvasView {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        layer.backgroundColor = UIColor.white.cgColor
        eventController.targetView = self
    }
}

// MARK: Drawing

private extension InnerCanvasView {
    func inkingBegan(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let pathLayer = DrawingLayer()
        inkingContext.pathLayer = pathLayer
        inkingContext.pathLayer?.use(tool: tool)
        inkingContext.points = [touch.location(in: self)]
        
        layer.addSublayer(pathLayer)
    }

    func inkingMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first, !inkingContext.points.isEmpty else { return }

        let touches = event?.coalescedTouches(for: touch) ?? [touch]
        inkingContext.points += touches.map { $0.location(in: self) }

        let predictedPoints = event?.predictedTouches(for: touch)?.map { $0.location(in: self) } ?? []
        
        inkingContext.pathLayer?.path = UIBezierPath.interpolate(points: inkingContext.points + predictedPoints).cgPath
    }

    func inkingEnded(touches: Set<UITouch>, event: UIEvent?) {
        if let inkingLayer = inkingContext.pathLayer {
            inkingLayer.path = UIBezierPath.interpolate(points: inkingContext.points).cgPath
            eventController.pushDrawingLineEvent(lineLayer: inkingLayer)
        }
        inkingContext.reset()
    }
}

// MARK: Eraser

extension InnerCanvasView {
    func eraserBegan(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let eraserLayer = EraserLayer()
        eraserContext.eraserLayer = eraserLayer
        eraserContext.eraserLayer?.use(tool: tool)
        eraserContext.points = [touch.location(in: self)]
        
        layer.addSublayer(eraserLayer)
    }
    
    func eraserMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first,
            !eraserContext.points.isEmpty else { return }

        eraserContext.points += [touch.location(in: self)]

        let path = UIBezierPath()
        path.move(to: eraserContext.points[0])
        eraserContext.points.forEach {
            path.addLine(to: $0)
        }
        eraserContext.eraserLayer?.path = path.cgPath
    }
    
    func eraserEnded(touches: Set<UITouch>, event: UIEvent?) {
        guard let eraserLayer = eraserContext.eraserLayer else { return }
        
        layer.sublayers?.forEach {
            guard let path = ($0 as? CAShapeLayer)?.path,
                let eraserPath = eraserLayer.path,
                $0 !== eraserLayer else { return }

            if path.boundingBoxOfPath.intersects(eraserPath.boundingBoxOfPath) {
                let copyLayer = CAShapeLayer()
                copyLayer.use(tool: tool)
                copyLayer.path = eraserLayer.path
                copyLayer.backgroundColor = UIColor.white.cgColor
                $0.addSublayer(copyLayer)
            }
        }
        eraserContext.reset()
    }
}

// MARK: Lasso

extension InnerCanvasView {
    func lassoBegan(touches: Set<UITouch>) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if lassoContext.lassoClosed {
            if lassoContext.lassoLayer?.path?.boundingBoxOfPath.contains(location) ?? false {
                lassoContext.moveCurrentPotision = location
            }

        } else {
            let lassoLayer = CAShapeLayer()
            lassoLayer.use(tool: tool)
            layer.addSublayer(lassoLayer)

            lassoContext.lassoLayer = lassoLayer
            lassoContext.points = [location]
        }
    }

    func lassoMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if lassoContext.lassoClosed {
            guard let lastLocation = lassoContext.moveCurrentPotision else { return }

            let location = touch.location(in: self)
            let dx = location.x - lastLocation.x
            let dy = location.y - lastLocation.y

            lassoContext.moveCurrentPotision = location
            lassoContext.dx += dx
            lassoContext.dy += dy

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            (lassoContext.lassoEnclosedLayers + [lassoContext.lassoLayer]).forEach {
                $0?.frame.origin.x += dx
                $0?.frame.origin.y += dy
            }
            CATransaction.commit()

        } else {
            let touches = event?.coalescedTouches(for: touch) ?? [touch]
            lassoContext.points += touches.map { $0.location(in: self) }

            let predictedPoints = event?.predictedTouches(for: touch)?.map { $0.location(in: self) } ?? []
            lassoContext.lassoLayer?.path = UIBezierPath.interpolate(points: lassoContext.points + predictedPoints).cgPath
        }
    }

    func lassoEnded(touches: Set<UITouch>, event: UIEvent?) {
        if lassoContext.lassoClosed {
            eventController.pushLassoEvent(context: lassoContext)
            lassoContext.reset()

        } else {
            let path = UIBezierPath.interpolate(points: lassoContext.points, closed: true).cgPath
            lassoContext.lassoLayer?.path = path
            lassoContext.points = []

            lassoContext.lassoEnclosedLayers = layer.sublayers?.filter {
                let isSelf = $0 === lassoContext.lassoLayer
                let enclosedShapeLayersExist = ($0 as? CAShapeLayer)?.movedBoundingBox.intersects(path.boundingBoxOfPath) ?? false
                let enclosedImageLayersExist = ($0 as? ImageLayer)?.frame.intersects(path.boundingBoxOfPath) ?? false
                return !isSelf && (enclosedShapeLayersExist || enclosedImageLayersExist)
                } ?? []

            if lassoContext.lassoEnclosedLayers.isEmpty {
                lassoContext.lassoLayer?.removeFromSuperlayer()
                
            } else {
                lassoContext.lassoClosed = true
                
                let animation = CABasicAnimation(keyPath: "lineDashPhase")
                animation.fromValue = 0
                animation.toValue = 16
                animation.duration = 0.2
                animation.repeatCount = .infinity
                lassoContext.lassoLayer?.add(animation, forKey: nil)
            }
        }
    }
}
