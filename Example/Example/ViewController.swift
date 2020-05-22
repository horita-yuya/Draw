import UIKit
import Draw

final class ViewController: UIViewController {
    @IBOutlet private var canvasView: CanvasView!
    @IBOutlet private var pencilButton: UIButton!
    @IBOutlet private var eraserButton: UIButton!
    @IBOutlet private var lassoButton: UIButton!
    @IBOutlet private var imageButton: UIButton!
    @IBOutlet private var captureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func undo(_ sender: Any) {
        canvasView.undo()
    }
    
    @IBAction func redo(_ sender: Any) {
        canvasView.redo()
    }
}

private extension ViewController {
    func configure() {
        pencilButton.addTarget(self, action: #selector(pencilSelected), for: .touchUpInside)
        eraserButton.addTarget(self, action: #selector(eraserSelected), for: .touchUpInside)
        lassoButton.addTarget(self, action: #selector(lassoSelected), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(imageSelected), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureSelected), for: .touchUpInside)

        pencilButton.setTitle("P", for: .normal)
        eraserButton.setTitle("E", for: .normal)
        lassoButton.setTitle("L", for: .normal)
        captureButton.setTitle("I", for: .normal)
        captureButton.setTitle("C", for: .normal)
        
        let header = UILabel()
        header.text = "Header"
        header.font = .boldSystemFont(ofSize: 40)
        header.textAlignment = .center
//        canvasView.addBackgroundImage(image: UIImage(named: "nachtwacht"))
    }
    
    @objc
    func pencilSelected() {
        canvasView.tool = InkingTool(inkType: .pen, color: .black)
    }
    
    @objc
    func eraserSelected() {
        canvasView.tool = EraserTool(.bitmap)
    }
    
    @objc
    func lassoSelected() {
        canvasView.tool = LassoTool()
    }
    
    @objc
    func imageSelected() {
        let view = UINib(nibName: "SampleImageView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SampleImageView
        canvasView.canvasImageView = view
    }
    
    @objc
    func captureSelected() {
        let image = canvasView.capture()
        let viewController = PreviewViewController(image: image)
        present(viewController, animated: true)
    }
}
