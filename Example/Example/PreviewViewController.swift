import UIKit

final class PreviewViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    
    private let image: UIImage?
    
    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
