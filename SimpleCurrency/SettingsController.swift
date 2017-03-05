import Eureka
import UIKit

class SettingsController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Settings", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        form +++ CurrencySelectorRow(tag: tagBaseCurrency) {
            row in
            row.title = NSLocalizedString("Base Currency", comment: "")
            row.value = Currencies(rawValue: UserDefaults.standard.string(forKey: "baseCurrency")!)!
        }
        
        <<< IntRow(tagBaseAmount) {
            row in
            row.title = NSLocalizedString("Base Amount", comment: "")
            row.value = UserDefaults.standard.integer(forKey: "baseAmount")
        }
        
        let section = Section(NSLocalizedString("Currencies", comment: ""))
        form +++ section
        
        for currency in Currencies.allValues {
            section <<< CheckRow(currency.currencyCode) {
                $0.title = currency.currencyCode
                $0.value = (UserDefaults.standard.array(forKey: "currencies") as! [String]).contains(currency.currencyCode)
                $0.cellStyle = .subtitle
                $0.baseCell.imageView!.image = UIImage(named: currency.currencyCode)
                $0.hidden = Condition.function([tagBaseCurrency]) {
                    form in
                    let baseCurrencyRow: CurrencySelectorRow = form.rowBy(tag: tagBaseCurrency)!
                    return currency == baseCurrencyRow.value
                }
            }.cellUpdate { cell, _ in
                    cell.detailTextLabel!.text = Currencies.fullNameDict[currency]!
            }
        }
    }
    
    @IBAction func done() {
        let values = form.values(includeHidden: false)
        if let baseCurrency = values[tagBaseCurrency] as? Currencies {
            UserDefaults.standard.set(baseCurrency.currencyCode, forKey: "baseCurrency")
        }
        
        if let baseAmount = values[tagBaseAmount] as? Int {
            UserDefaults.standard.set(baseAmount, forKey: "baseAmount")
        }
        
        let currencies = Currencies.allValues.filter { (values[$0.currencyCode] as? Bool) == true }.map { $0.currencyCode }
        UserDefaults.standard.set(currencies, forKey: "currencies")
        
        performSegue(withIdentifier: "unwindToExchangeRates", sender: self)
    }
}
