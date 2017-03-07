import UIKit
import Eureka
import Alamofire
import SCLAlertView
import SwiftyJSON

class CurrencyConverterController: FormViewController {

    var currency1: Currencies!
    var currency2: Currencies!
    var rate: Double!
    var reverseRate: Double {
        return pow(rate!, -1)
    }
    
}
