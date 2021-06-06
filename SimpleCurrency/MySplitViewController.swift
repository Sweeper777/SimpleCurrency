import UIKit

class MySplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        preferredDisplayMode = .allVisible
        self.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        //        guard let topAsDetailController = secondaryAsNavController.topViewController as? CurrencyConverterController else { return false }
        //        if topAsDetailController.shouldBeEmpty {
        //            return true
        //        }
        return true
    }
}
