import UIKit
import ESPullToRefresh
import Alamofire
import SwiftyJSON
import SCLAlertView
import GoogleMobileAds
import PromiseKit

class ExchangeRatesController: UITableViewController {
    var baseCurrency: String!
    var baseAmount: Double!
    var currencies: [String]!
    var currencyToPass: Currencies!
    
    var json: JSON!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        if let cache = UserDefaults.standard.data(forKey: "lastData") {
            json = JSON(data: cache)
        }
        loadSettings()
        requestData()
        
        tableView.es_addPullToRefresh {
            self.requestData()
        }
    }
    
    func loadSettings() {
        currencies = UserDefaults.standard.array(forKey: "currencies")!.map { $0 as! String }
        baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")
        baseAmount = UserDefaults.standard.double(forKey: "baseAmount")
    }
    
    func requestData() {
        let url = "http://data.fixer.io/latest?access_key=\(apiKey)&base=\(baseCurrency!)&symbols=\(currencies.joined(separator: ","))"
        
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
            self.json = json
            UserDefaults.standard.set(try? json.rawData(), forKey: "lastData")
            self.tableView.reloadData()
            return Promise(value: json)
        }.always {
            self.tableView.es_stopPullToRefresh()
        }.catch {_ in
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
            alert.addButton(NSLocalizedString("OK", comment: ""), action: {})
            alert.showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Unable to get exchange rates.", comment: ""))
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
            request.testDevices = [kGADSimulatorID]
            banner.rootViewController = self
            banner.adUnitID = adUnitID1
            banner.load(request)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.imageView!.image = UIImage(named: currencies[indexPath.row - 1])
        cell.textLabel!.text = NSLocalizedString("No Data", comment: "")
        cell.detailTextLabel!.text = Currencies(rawValue: currencies[indexPath.row - 1])!.fullName
        
        guard let json = self.json else { return cell }
        guard let rate = json["rates"][currencies[indexPath.row - 1]].double else { return cell }
        
        cell.textLabel!.text = "\(rate) \(currencies[indexPath.row - 1]) (\(Currencies(rawValue: currencies[indexPath.row - 1])!.symbol))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = json["rates"][currencies[indexPath.row - 1]].double {
            currencyToPass = Currencies(rawValue: currencies[indexPath.row - 1])
            performSegue(withIdentifier: "showConverter", sender: self)
        }
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
                requestData()
            }
        }
    }
}
