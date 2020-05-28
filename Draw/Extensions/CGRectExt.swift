import UIKit

extension CGRect {
    func convertToPoints(bin: Int = 16) -> [CGPoint] {
        let gapX = (maxX - minX) / .init(bin)
        let gapY = (maxY - minY) / .init(bin)
        
        var points: [CGPoint] = []
        for i in 0 ... bin {
            for j in 0 ... bin {
                points.append(.init(x: gapX * .init(i) + minX, y: gapY * .init(j) + minY))
            }
        }
        return points
    }
}
