import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController {
    
    @IBOutlet var sevenDayChart: Chart!
    @IBOutlet var thirtyDayChart: Chart!
    
    let last30Days: [Date] = {
        var dates = [Date]()
        for i in 0...29 {
            let day = Date().date.addingTimeInterval(Double(-60 * 60 * 24 * (29 - i)))
            dates.append(day)
        }
        
        return dates
    }()
    
    var last7Days: [Date] {
        return Array(last30Days.dropFirst(23))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRate(completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }

}
