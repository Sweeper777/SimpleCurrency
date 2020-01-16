import UIKit
import Eureka

class TodayExtensionSettingsController : UITableViewController {
    
    var selectedCurrencyIndices: [Int] = []
    var availableCurrencies: [Currencies] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let baseCurrency = UserDefaults.shared.string(forKey: "baseCurrency")
        availableCurrencies = Currencies.allCases.filter { $0.currencyCode != baseCurrency }
        let selectedCurrencies = UserDefaults.shared.array(forKey: "todayExtensionCurrencies") as! [String]
        selectedCurrencyIndices = selectedCurrencies.compactMap(Currencies.init).compactMap(availableCurrencies.firstIndex)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = "\(availableCurrencies[indexPath.row].currencyCode) (\(availableCurrencies[indexPath.row].symbol))"
        cell.imageView!.image = UIImage(named: availableCurrencies[indexPath.row].currencyCode)
        cell.detailTextLabel!.text = availableCurrencies[indexPath.row].fullName
        if let _ = selectedCurrencyIndices.firstIndex(of: indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedCurrencyIndices.firstIndex(of: indexPath.row) {
            selectedCurrencyIndices.remove(at: index)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else if selectedCurrencyIndices.count < 3 {
            selectedCurrencyIndices.append(indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        let selectedCurrencies = selectedCurrencyIndices.map { availableCurrencies[$0].currencyCode }
        UserDefaults.shared.set(selectedCurrencies, forKey: "todayExtensionCurrencies")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
