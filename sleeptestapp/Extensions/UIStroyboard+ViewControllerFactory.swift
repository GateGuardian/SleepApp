
import UIKit

public extension UIStoryboard {
    enum Storyboard: String {
        case main = "Main"
    }
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        let identifier = String(describing: T.self)
        guard let viewController = self.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(identifier)")
        }
        return viewController
    }
}

