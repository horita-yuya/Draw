import UIKit
import Draw

final class SampleImageView: UIView, CanvasImageViewProtocol {
    @IBOutlet private(set) var imageView: UIImageView!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    var confirmSelected: (() -> Void)?
    var cancelSelected: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        confirmButton.addTarget(self, action: #selector(conf), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(canc), for: .touchUpInside)
    }
    
    @objc func conf() {
        confirmSelected?()
    }
    
    @objc func canc() {
        cancelSelected?()
    }
}
