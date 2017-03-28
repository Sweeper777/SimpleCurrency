import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController {
    
    @IBOutlet var sevenDayChart: Chart!
    @IBOutlet var thirtyDayChart: Chart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRate(completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }

}
