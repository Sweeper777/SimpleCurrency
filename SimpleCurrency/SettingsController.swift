import Eureka
import UIKit

class SettingsController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Settings", comment: "")
        
        form +++ PickerInlineRow<Currencies>(tagBaseCurrency) {
            row in
            row.title = NSLocalizedString("Base Currency", comment: "")
            row.options = Currencies.allValues
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
            }.cellUpdate { cell, _ in
                    cell.detailTextLabel!.text = Currencies.fullNameDict[currency]!
            }
        }
    }
}
