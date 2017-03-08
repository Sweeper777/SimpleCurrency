import Eureka
import UIKit

class SettingsController: FormViewController {
    var settingsHasChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Settings", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        form +++ CurrencySelectorRow(tag: tagBaseCurrency) {
            row in
            row.title = NSLocalizedString("Base Currency", comment: "")
            row.value = Currencies(rawValue: UserDefaults.standard.string(forKey: "baseCurrency")!)!
        }
        
        <<< DecimalRow(tagBaseAmount) {
            row in
            row.title = NSLocalizedString("Base Amount", comment: "")
            row.value = UserDefaults.standard.double(forKey: "baseAmount")
        }
        
        let section = Section(NSLocalizedString("Currencies", comment: ""))
        form +++ section
        
        let selectButton = ButtonRow(tagSelectAll) {
            row in
            row.title = NSLocalizedString("Select All", comment: "")
        }.onCellSelection {
            _ in
            for currency in Currencies.allValues {
                if let row: CheckRow = self.form.rowBy(tag: currency.currencyCode) {
                    row.value = true
                    row.updateCell()
                }
            }
        }
        section <<< selectButton
        
        let deselectButton = ButtonRow(tagDeselectAll) {
            row in
            row.title = NSLocalizedString("Deselect All", comment: "")
            }.onCellSelection {
                _ in
                for currency in Currencies.allValues {
                    if let row: CheckRow = self.form.rowBy(tag: currency.currencyCode) {
                        row.value = false
                        row.updateCell()
                    }
                }
        }
        section <<< deselectButton
        
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
        
        var dependentRowTags = Currencies.allValues.map { $0.currencyCode }
        dependentRowTags.append(tagBaseCurrency)
        selectButton.hidden = Condition.function(dependentRowTags) {
            form in
            let baseCurrency = (form.rowBy(tag: tagBaseCurrency) as! CurrencySelectorRow).value
            for currency in Currencies.allValues where currency != baseCurrency {
                guard let row: CheckRow = form.rowBy(tag: currency.currencyCode) else {
                    return false
                }
                
                if row.isHidden {
                    continue
                }
                
                if row.value == false {
                    return false
                }
            }
            return true
        }
        deselectButton.hidden = Condition.function(dependentRowTags) {
            form in
            let baseCurrency = (form.rowBy(tag: tagBaseCurrency) as! CurrencySelectorRow).value
            for currency in Currencies.allValues where currency != baseCurrency {
                guard let row: CheckRow = form.rowBy(tag: currency.currencyCode) else {
                    return false
                }
                
                if row.isHidden {
                    continue
                }
                
                if row.value == true {
                    return false
                }
            }
            return true
        }
        (form.allRows[10] as! CheckRow).value = !(form.allRows[10] as! CheckRow).value!
        (form.allRows[10] as! CheckRow).value = !(form.allRows[10] as! CheckRow).value!
    }
    
    @IBAction func done() {
        let values = form.values(includeHidden: false)
        var baseCurrencyChanged = false
        var baseAmountChanged = false
        var currenciesChanged = false
        if let baseCurrency = values[tagBaseCurrency] as? Currencies {
            if baseCurrency.currencyCode != UserDefaults.standard.string(forKey: "baseCurrency") {
                baseCurrencyChanged = true
                UserDefaults.standard.set(baseCurrency.currencyCode, forKey: "baseCurrency")
            }
        }
        
        if let baseAmount = values[tagBaseAmount] as? Double {
            if baseAmount != UserDefaults.standard.double(forKey: "baseAmount") && baseAmount != 0 {
                baseAmountChanged = true
                UserDefaults.standard.set(baseAmount, forKey: "baseAmount")
            }
        }
        
        let currencies = Currencies.allValues.filter { (values[$0.currencyCode] as? Bool) == true }.map { $0.currencyCode }
        let oldArray = UserDefaults.standard.array(forKey: "currencies") as! [String]
        if !(currencies.contains(array: oldArray) && currencies.count == oldArray.count) {
            currenciesChanged = true
            UserDefaults.standard.set(currencies, forKey: "currencies")
        }
        
        settingsHasChanged = baseCurrencyChanged || baseAmountChanged || currenciesChanged
        
        performSegue(withIdentifier: "unwindToExchangeRates", sender: self)
    }
}
