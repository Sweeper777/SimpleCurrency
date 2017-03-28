import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRate(completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }

}
