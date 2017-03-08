import UIKit
import Eureka
import Alamofire
import SCLAlertView
import SwiftyJSON
import SwiftyUtils

class CurrencyConverterController: FormViewController {

    var currency1: Currencies!
    var currency2: Currencies!
    var rate: Double!
    var reverseRate: Double {
        return pow(rate, -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        form +++ LabelRow(tagToRate) {
            row in
            row.title = "1 \(currency1!) = \(rate!) \(currency2!)"
        }
        
        <<< LabelRow(tagFromRate) {
            row in
            row.title = "1 \(currency2!) = \(reverseRate) \(currency1!)"
        }
        
    }
}
