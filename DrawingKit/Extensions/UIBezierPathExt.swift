import UIKit

extension UIBezierPath {
    static func interpolate(points: [CGPoint], closed: Bool = false) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points[0])
        points.forEach {
            path.addLine(to: $0)
        }
        if closed {
            path.close()
        }
        return path
    }
}
