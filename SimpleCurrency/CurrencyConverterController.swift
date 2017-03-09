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
    
    var formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.numberStyle = .decimal
        
        form +++ LabelRow(tagToRate) {
            row in
            row.title = "1 \(currency1!) = \(formatter.string(from: rate as NSNumber)!) \(currency2!)"
        }
        
        <<< LabelRow(tagFromRate) {
            row in
            row.title = "1 \(currency2!) = \(formatter.string(from: reverseRate as NSNumber)!) \(currency1!)"
        }
        
        form +++ DecimalRow(tagCurrency1Convert) {
            row in
            row.title = "\(currency1.currencyCode):"
            row.cell.textField.placeholder = "0.00"
        }
        
        <<< DecimalRow(tagCurrency2Convert) {
            row in
            row.title = "\(currency2.currencyCode):"
            row.cell.textField.placeholder = "0.00"
        }
    }
}
