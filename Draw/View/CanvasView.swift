import UIKit
import PencilKit

public class CanvasView: UIView {
    private var innerCanvas: UIView?
    
    public var usePencilKitIfPossible: Bool = false
    
    @available(iOS 13, *)
    internal var pkCanvas: PKCanvasView! {
        get { innerCanvas as? PKCanvasView }
        set { innerCanvas = newValue }
    }

    internal var canvas: InnerCanvasView! {
        get { innerCanvas as? InnerCanvasView }
        set { innerCanvas = newValue }
    }
    
    var data: Data? {
        if #available(iOS 13, *) {
            return pkCanvas.drawing.dataRepresentation()
        } else {
            return nil
        }
    }
    
    public var tool: DrawingTool {
        get {
            if #available(iOS 13, *), usePencilKitIfPossible {
                return createDrawingTool(from: pkCanvas.tool)
            } else {
                return canvas.tool
            }
        }
        set {
            if #available(iOS 13, *), usePencilKitIfPossible {
                pkCanvas.tool = newValue.toPKTool()
            } else {
                canvas.tool = newValue
            }
        }
    }
    
    public var canvasImageView: CanvasImageViewProtocol? {
        get {
            if #available(iOS 13, *), usePencilKitIfPossible {
                // This is not supported
                return nil
            } else {
                return canvas.canvasImageView
            }
        }
        set {
            if #available(iOS 13, *), usePencilKitIfPossible {
                // Do nothing
            } else {
                canvas.canvasImageView = newValue
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    public func capture() -> UIImage? {
        if #available(iOS 13, *), usePencilKitIfPossible {
            return pkCanvas.drawing.image(from: bounds, scale: 0)
            
        } else {
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            let render = UIGraphicsImageRenderer(bounds: bounds, format: format)
            
            return render.image { ctx in
                layer.render(in: ctx.cgContext)
            }
        }
    }
    
    public func addBackgroundImage(image: UIImage?) {
        if #available(iOS 13, *), usePencilKitIfPossible {
            
        } else {
            canvas.image = image
        }
    }
   
    public func reset() {
        if #available(iOS 13, *), usePencilKitIfPossible {
            
        } else {
            canvas.reset()
        }
    }
}

private extension CanvasView {
    func configure() {
        if #available(iOS 13, *), usePencilKitIfPossible {
            setupPKCanvas()
            
        } else {
            setupInnerCanvas()
        }
    }
    
    @available(iOS 13, *)
    func setupPKCanvas() {
        pkCanvas = PKCanvasView()
        pkCanvas.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(pkCanvas, at: 0)
        pkCanvas.edgesToSuperview()
    }

    func setupInnerCanvas() {
        canvas = InnerCanvasView(frame: .zero)
        insertSubview(canvas, at: 0)
        canvas.edgesToSuperview()
    }
    
    @available(iOS 13, *)
    func createDrawingTool(from pktool: PKTool) -> DrawingTool {
        if let inkingTool = pktool as? PKInkingTool {
            return InkingTool(inkType: inkingTool.inkType.toInkType, color: inkingTool.color, width: inkingTool.width)
            
        } else if let eraserTool = pktool as? PKEraserTool {
            return EraserTool(eraserTool.eraserType.toEraserType)
            
        } else if pktool is PKLassoTool {
            return LassoTool()
            
        } else {
            fatalError("\(pktool) is unsupported")
        }
    }
}
