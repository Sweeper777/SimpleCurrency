import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController {
    var currency: Currencies!
    
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

    func getRate(completion: (() -> Void)?) {
        let baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for date in last30Days {
            let dateString = formatter.string(from: date)
            let url = "https://api.fixer.io/\(dateString)?base=\(baseCurrency!)&symbols=\(currency!)"
            Alamofire.request(url).responseString {
                [weak self]
                response in
                if let _ = response.error {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
                    alert.addButton(NSLocalizedString("OK", comment: ""), action: {})
                    alert.showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
                    completion?()
                    return
                }
                
                let json = JSON(parseJSON: response.value!)
                if let _ = json["error"].string {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
                    alert.addButton(NSLocalizedString("OK", comment: ""), action: {})
                    alert.showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
                    completion?()
                    return
                }
                
                if self != nil {
                    if let rate = json["rates"][self!.currency.currencyCode].double {
                        self!.rates[date] = rate
                    }
                }
            }
            completion?()
        }
    }
}
