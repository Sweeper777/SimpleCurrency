import UIKit
import SVPullToRefresh
import Alamofire
import SwiftyJSON
import SCLAlertView
import GoogleMobileAds

class ExchangeRatesController: UITableViewController {
    var baseCurrency: String!
    var baseAmount: Double!
    var currencies: [String]!
    var currencyToPass: Currencies!
    
    var json: JSON!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        if let cache = UserDefaults.shared.data(forKey: "lastData") {
            json = try! JSON(data: cache)
        }
        loadSettings()
        requestData(completion: nil)
        
        self.tableView.addPullToRefresh {
            [weak self] in
            self?.requestData(completion: {
                [weak self] in
                self?.tableView.pullToRefreshView.stopAnimating()
            })
        }
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func loadSettings() {
        currencies = UserDefaults.shared.array(forKey: "currencies")!.map { $0 as! String }
        baseCurrency = UserDefaults.shared.string(forKey: "baseCurrency")
        baseAmount = UserDefaults.shared.double(forKey: "baseAmount")
    }
    
    func requestData(completion: (() -> Void)?) {
        let url = "https://api.exchangeratesapi.io/latest?base=\(baseCurrency!)&symbols=\(currencies.joined(separator: ","))&amount=\(baseAmount!)"
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
            self?.json = json
            UserDefaults.shared.set(try? json.rawData(), forKey: "lastData")
            _ = Timer.after(0.1) {
                DispatchQueue.main.async {
                    completion?()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(baseAmount!) \(baseCurrency!) = ?"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ad")!
            let banner = cell.viewWithTag(1) as! GADBannerView
            let request = GADRequest()
            banner.rootViewController = self
            banner.adUnitID = adUnitID1
            banner.load(request)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.imageView!.image = UIImage(named: currencies[indexPath.row - 1])
//        cell.imageView!.image = UIImage(named: currencies[indexPath.row])
        cell.textLabel!.text = NSLocalizedString("No Data", comment: "")
        cell.detailTextLabel!.text = Currencies(rawValue: currencies[indexPath.row - 1])!.fullName
//        cell.detailTextLabel!.text = Currencies(rawValue: currencies[indexPath.row])!.fullName
        
        guard let json = self.json else { return cell }
        guard let rate = json["rates"][currencies[indexPath.row - 1]].double else { return cell }
//        guard let rate = json["rates"][currencies[indexPath.row]].double else { return cell }
        
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 5
        let rateString = formatter.string(from: rate as NSNumber)!
        
        cell.textLabel!.text = "\(rateString) \(currencies[indexPath.row - 1]) (\(Currencies(rawValue: currencies[indexPath.row - 1])!.symbol))"
//        cell.textLabel!.text = "\(rateString) \(currencies[indexPath.row]) (\(Currencies(rawValue: currencies[indexPath.row])!.symbol))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = json?["rates"][currencies[indexPath.row - 1]].double {
            currencyToPass = Currencies(rawValue: currencies[indexPath.row - 1])
//        if let _ = json?["rates"][currencies[indexPath.row]].double {
//            currencyToPass = Currencies(rawValue: currencies[indexPath.row])
            performSegue(withIdentifier: "showConverter", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? CurrencyConverterController {
            vc.currency1 = Currencies(rawValue: baseCurrency)
            vc.currency2 = currencyToPass
            vc.rate = json["rates"][currencyToPass.currencyCode].doubleValue / baseAmount
            vc.shouldBeEmpty = false
        }
    }
    
    @IBAction func unwindFromSettings(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? SettingsController {
            if vc.settingsHasChanged {
                loadSettings()
                requestData(completion: nil)
            }
        }
    }
}
