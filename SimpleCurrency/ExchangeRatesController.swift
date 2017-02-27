import UIKit
import ESPullToRefresh
import Alamofire
import SwiftyJSON
import SCLAlertView

class ExchangeRatesController: UITableViewController {
    var baseCurrency: String!
    var baseAmount: Double!
    var currencies: [String]!
    
    var json: JSON!
    
    override func viewDidLoad() {
        currencies = UserDefaults.standard.array(forKey: "currencies")!.map { $0 as! String }
        baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")
        baseAmount = UserDefaults.standard.double(forKey: "baseAmount")
        Alamofire.request("https://api.fixer.io/latest?base=\(baseCurrency)&symbols=\(currencies.joined(separator: ","))&amount=\(baseAmount)").responseData {
            [weak self]
            response in
            if let _ = response.error {
                _ = SCLAlertView().showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
                return
            }
            
            let json = JSON(data: response.value!)
            if let _ = json["error"].string {
                _ = SCLAlertView().showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
            }
            self?.json = json
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
}

