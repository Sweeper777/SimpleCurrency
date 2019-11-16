import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var baseCurrencyLabel: UILabel!
    @IBOutlet var currencyLabel1: UILabel!
    @IBOutlet var currencyLabel2: UILabel!
    @IBOutlet var currencyLabel3: UILabel!
    @IBOutlet var blur: UIVisualEffectView!
    
    var displayedCurrencies: [Currencies] = []
    var baseCurrency: Currencies!
    var baseAmount: Double!
    
    var json: JSON!
    var rates: [Currencies: Double] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
