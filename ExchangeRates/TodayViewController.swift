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
    var ratesYesterday: [Currencies: Double] = [:]
    
    var lastRequestTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 13.0, *) {
            blur.effect = UIVibrancyEffect.widgetEffect(forVibrancyStyle: .label)
        } else {
            blur.effect = UIVibrancyEffect.widgetPrimary()
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadUserDefaults()
        if let lastRequestTime = self.lastRequestTime {
            if Date().timeIntervalSince(lastRequestTime) < 60 * 60 &&
                Set(rates.keys).isSuperset(of: displayedCurrencies) &&
                Set(ratesYesterday.keys).isSuperset(of: displayedCurrencies) {
                resetLabelText()
                completionHandler(.noData)
                return
            }
        }
        reload { (success) in
            if !success {
                print("failed!")
            }
            completionHandler(success ? .newData : .failed)
        }
    }
    
    func reload(completion: ((Bool) -> Void)?) {
        lastRequestTime = Date()
        requestLatestData { [weak self] (success) in
            guard let `self` = self else { return }
            guard success else {
                completion?(false)
                return
            }
            for currency in self.displayedCurrencies {
                self.rates[currency] = self.json["rates"][currency.currencyCode].double
            }
            self.requestYesterdayData { [weak self] (success) in
                guard let `self` = self else { return }
                guard success else {
                    completion?(false)
                    return
                }
                for currency in self.displayedCurrencies {
                    self.ratesYesterday[currency] = self.json["rates"][currency.currencyCode].double
                }
                self.resetLabelText()
            }
        }
    }
    
    private func loadUserDefaults() {
        baseCurrency = UserDefaults.shared.string(forKey: "baseCurrency").flatMap(Currencies.init)
        baseAmount = UserDefaults.shared.double(forKey: "baseAmount")
        displayedCurrencies = (UserDefaults.shared.array(forKey: "todayExtensionCurrencies") as! [String])
            .filter { $0 != baseCurrency.currencyCode }.compactMap(Currencies.init)
        for (index, label) in [currencyLabel1, currencyLabel2, currencyLabel3].enumerated() {
            if index < displayedCurrencies.count {
                label?.isHidden = false
            } else {
                label?.isHidden = true
            }
        }
    }
    
    private func requestLatestData(completion: ((Bool) -> Void)?) {
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
    
    private func requestYesterdayData(completion: ((Bool) -> Void)?) {
        let yesterday = Date().addingTimeInterval(60 * 60 * -24)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterdayString = formatter.string(from: yesterday)
        let url = "https://api.exchangeratesapi.io/\(yesterdayString)?base=\(baseCurrency.currencyCode)&symbols=\(displayedCurrencies.map { $0.currencyCode }.joined(separator: ","))&amount=\(baseAmount!)"
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
            let rateYesterday = ratesYesterday[currency]!
            let deltaString: String
            let deltaStringColor: UIColor
            if rateYesterday - rate > 0.01 {
                deltaString = "⬇︎"
                deltaStringColor = .red
            } else if rate - rateYesterday > 0.01 {
                deltaString = "⬆︎"
                deltaStringColor = .green
            } else {
                deltaString = ""
                if #available(iOSApplicationExtension 13.0, *) {
                    deltaStringColor = .label
                } else {
                    deltaStringColor = .black
                }
            }
            label?.text = "\(formatter.string(from: rate as NSNumber)!) \(currency.currencyCode) \(deltaString)"
        }
        baseCurrencyLabel.text = "\(formatter.string(from: baseAmount as NSNumber)!) \(baseCurrency.currencyCode) = "
    }
}
