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
        if #available(iOSApplicationExtension 13.0, *) {
            blur.effect = UIVibrancyEffect.widgetEffect(forVibrancyStyle: .label)
        } else {
            blur.effect = UIVibrancyEffect.widgetPrimary()
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    
    private func loadUserDefaults() {
        baseCurrency = UserDefaults.shared.string(forKey: "baseCurrency").flatMap(Currencies.init)
        baseAmount = UserDefaults.shared.double(forKey: "baseAmount")
        displayedCurrencies = []
        let defaultsKeys = (0..<3).map { "todayExtensionCurrency\($0)" }
        for (key, label) in zip(defaultsKeys, [currencyLabel1, currencyLabel2, currencyLabel3]) {
            if let currency = UserDefaults.shared.string(forKey: key) {
                if currency == baseCurrency.currencyCode {
                    label?.isHidden = true
                } else {
                    displayedCurrencies.append(Currencies(rawValue: currency)!)
                    label?.isHidden = false
                }
            } else {
                label?.isHidden = true
            }
        }
    }
    
    private func requestData(completion: ((Bool) -> Void)?) {
        let url = "https://api.exchangeratesapi.io/latest?base=\(baseCurrency.currencyCode)&symbols=\(displayedCurrencies.map { $0.currencyCode }.joined(separator: ","))&amount=\(baseAmount!)"
        Alamofire.request(url).responseString {
            [weak self]
            response in
            if let _ = response.error {
                completion?(false)
                return
            }
            
            let json = JSON(parseJSON: response.value!)
            if let _ = json["error"].string {
                completion?(false)
                return
            }
            self?.json = json
            DispatchQueue.main.async {
                completion?(true)
            }
        }
    }
    
    private func resetLabelText() {
        let shownLabels = [currencyLabel1, currencyLabel2, currencyLabel3].filter { !$0!.isHidden }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        for (currency, label) in zip(displayedCurrencies, shownLabels) {
            let rate = rates[currency]!
            label?.text = "\(formatter.string(from: rate as NSNumber)!) \(currency.currencyCode)"
        }
        baseCurrencyLabel.text = "\(formatter.string(from: baseAmount as NSNumber)!) \(baseCurrency.currencyCode) = "
    }
}
