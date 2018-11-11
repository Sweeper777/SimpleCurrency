import UIKit
import Eureka
import Alamofire
import SCLAlertView
import SwiftyJSON
import SwiftyUtils
import GoogleMobileAds

class CurrencyConverterController: FormViewController, GADInterstitialDelegate {

    var shouldBeEmpty = true
    var currency1: Currencies!
    var currency2: Currencies!
    var rate: Double!
    var interstitialAd: GADInterstitial!
    
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
        if shouldBeEmpty {
            form +++ LabelRow(tagNothing) {
                row in
                row.title = NSLocalizedString("Please select a currency!", comment: "")
            }
            return
        }
        form +++ LabelRow(tagToRate) {
            row in
            row.title = "1 \(currency1!) = \(formatter.string(from: rate as NSNumber)!) \(currency2!)"
        }
        
        <<< LabelRow(tagFromRate) {
            row in
            row.title = "1 \(currency2!) = \(formatter.string(from: reverseRate as NSNumber)!) \(currency1!)"
        }
        
        form +++ CurrencyConverterRow(tagCurrency1Convert) {
            row in
            row.title = "\(currency1.currencyCode) (\(currency1.symbol)):"
            row.cell.textField.placeholder = "0.00"
            row.cell.imageView!.image = UIImage(named: currency1.currencyCode)
            row.formatter = nil
        }
        .onChange {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency2Convert)!
                resultRow.cell.textField.text = self.formatter.string(from: (value * self.rate) as NSNumber)!
            }
            let randomNumber = arc4random_uniform(100)
            print(randomNumber)
            if randomNumber < 6 {
                if self.interstitialAd.isReady && !self.interstitialAd.hasBeenUsed {
                    self.interstitialAd.present(fromRootViewController: self)
                }
            }
        }
        .onEndEditing {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency2Convert)!
                resultRow.value = value * self.rate
            }
        }
        
        <<< CurrencyConverterRow(tagCurrency2Convert) {
            row in
            row.title = "\(currency2.currencyCode) (\(currency2.symbol)):"
            row.cell.textField.placeholder = "0.00"
            row.cell.imageView!.image = UIImage(named: currency2.currencyCode)
            row.formatter = nil
        }
        .onChange {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency1Convert)!
                resultRow.cell.textField.text = self.formatter.string(from: (value * self.reverseRate) as NSNumber)!
            }
            let randomNumber = arc4random_uniform(100)
            if randomNumber < 6 {
                if self.interstitialAd.isReady && !self.interstitialAd.hasBeenUsed {
                    self.interstitialAd.present(fromRootViewController: self)
                }
            }
        }
        .onEndEditing {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency1Convert)!
                resultRow.value = value * self.reverseRate
            }
        }
        
        form +++ ButtonRow(tagHistoriicalRates) {
            row in
            row.title = NSLocalizedString("Historical Rates", comment: "")
        }
        .onCellSelection {
            _ in
            self.performSegue(withIdentifier: "showHistorical", sender: self)
        }
        
        tableView!.es_addPullToRefresh {
            [weak self] in
            self?.getRate {
                self?.reloadRates()
                self?.tableView?.es_stopPullToRefresh()
            }
        }
        
        interstitialAd = GADInterstitial(adUnitID: adUnitID2)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }

    func getRate(completion: (() -> Void)?) {
        let url = "https://api.fixer.io/latest?base=\(currency1!)&symbols=\(currency2!)"
        Promise<String> { fulfill, reject in
            Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString {
                                response in
                                if let err = response.error {
                                    reject(err)
                                    return
                                } else {
                                    fulfill(response.value!)
                                }
            }
            }.then { str in
                Promise<JSON> { fulfill, reject in
                    let json = JSON(parseJSON: str)
                    if let _ = json["error"].string {
                        reject(NSError())
                    } else {
                        fulfill(json)
                    }
                }
            }.then { json -> Promise<JSON> in
                if let rate = json["rates"][self.currency2.currencyCode].double {
                    self.rate = rate
                }
                UserDefaults.standard.set(try? json.rawData(), forKey: "lastData")
                self.tableView?.reloadData()
                return Promise(value: json)
            }.always {
                self.reloadRates()
                self.tableView?.es_stopPullToRefresh()
            }.catch {_ in
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
                alert.addButton(NSLocalizedString("OK", comment: ""), action: {})
                alert.showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
                completion?()
                return
            }
            
            if self != nil {
                if let rate = json["rates"][self!.currency2.currencyCode].double {
                    self?.rate = rate
                }
            }
            completion?()
        }
    }
    
    func reloadRates() {
        var row: LabelRow = form.rowBy(tag: tagToRate)!
        row.title = "1 \(currency1!) = \(rate!) \(currency2!)"
        row = form.rowBy(tag: tagFromRate)!
        row.title = "1 \(currency2!) = \(reverseRate) \(currency1!)"
        
        var resultRow: CurrencyConverterRow = form.rowBy(tag: tagCurrency1Convert)!
        resultRow.value = 0
        resultRow = form.rowBy(tag: tagCurrency2Convert)!
        resultRow.value = 0
        form.allRows.forEach { $0.updateCell() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? HistoricalRatesController {
            vc.currency = currency2
        }
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = GADInterstitial(adUnitID: adUnitID2)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        interstitialAd = GADInterstitial(adUnitID: adUnitID2)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }
}
