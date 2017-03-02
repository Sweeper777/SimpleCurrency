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
        
    }
}
