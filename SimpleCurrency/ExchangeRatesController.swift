import UIKit
import ESPullToRefresh
import Alamofire
import SwiftyJSON
import SCLAlertView

class ExchangeRatesController: UITableViewController {
    var baseCurrency: String!
    var baseAmount: Int!
    var currencies: [String]!
    
    var json: JSON!
    
    override func viewDidLoad() {
        loadSettings()
        requestData(completion: nil)
        
        tableView.es_addPullToRefresh {
            self.requestData(completion: { 
                self.tableView.es_stopPullToRefresh()
            })
        }
    }
    
    func loadSettings() {
        currencies = UserDefaults.standard.array(forKey: "currencies")!.map { $0 as! String }
        baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")
        baseAmount = UserDefaults.standard.integer(forKey: "baseAmount")
    }
    
    func requestData(completion: (() -> Void)?) {
        let url = "https://api.fixer.io/latest?base=\(baseCurrency!)&symbols=\(currencies.joined(separator: ","))&amount=\(baseAmount!)"
        print(url)
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
            _ = Timer.after(0.1) {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    completion?()
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
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.imageView!.image = UIImage(named: currencies[indexPath.row])
        cell.textLabel!.text = NSLocalizedString("No Data", comment: "")
        cell.detailTextLabel!.text = Currencies.fullNameDict[Currencies(rawValue: currencies[indexPath.row])!]!
        
        guard let json = self.json else { return cell }
        guard let rate = json["rates"][currencies[indexPath.row]].double else { return cell }
        
        cell.textLabel!.text = "\(rate) \(currencies[indexPath.row])"
        
        return cell
    }
    
    @IBAction func unwindFromSettings(_ segue: UIStoryboardSegue) {
        loadSettings()
        requestData(completion: nil)
    }
}
