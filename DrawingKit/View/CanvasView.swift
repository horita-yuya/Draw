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
            return canvas.captureBackground()
        }
    }
    
    public func addFrameView(frameView: UIView) {
        if #available(iOS 13, *), usePencilKitIfPossible {
            // Do nothing
        } else {
            canvas.addSubview(frameView)
            frameView.translatesAutoresizingMaskIntoConstraints = false
            frameView.edgesToSuperview()
        }
    }
    
    public func addHeaderFrameView(headerFrameView: UIView, height: CGFloat) {
        if #available(iOS 13, *), usePencilKitIfPossible {
            // Do nothing
        } else {
            canvas.addSubview(headerFrameView)
            headerFrameView.translatesAutoresizingMaskIntoConstraints = false
            headerFrameView.edgesToTop(with: height)
        }
    }
    
    public func addBackgroundImage(image: UIImage?) {
        if #available(iOS 13, *), usePencilKitIfPossible {
            
        } else {
            canvas.image = image
        }
    }
    
    public func undo() {
        if #available(iOS 13, *), usePencilKitIfPossible {
            pkCanvas.undoManager?.undo()
            
        } else {
            canvas.undo()
        }
    }
    
    public func redo() {
        if #available(iOS 13, *), usePencilKitIfPossible {
            pkCanvas.undoManager?.redo()
            
        } else {
            canvas.redo()
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
