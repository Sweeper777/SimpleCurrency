import UIKit
import Eureka

class TodayExtensionSettingsController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = Section("Currencies")
        for i in 0..<3 {
            section <<< CurrencySelectorRow(tag: tagTodayExtensionCurrency + "\(i)") {
                row in
                row.title = String(format: NSLocalizedString("Currency %d", comment: ""), i + 1)
                row.value = UserDefaults.shared.string(forKey: "todayExtensionCurrency\(i)").flatMap(Currencies.init)
            }
            .onChange({ (row) in
                UserDefaults.shared.set(row.value?.currencyCode, forKey: "todayExtensionCurrency\(i)")
            })
        }
        form +++ section
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CurrencySelectorController {
            vc.allowNilValue = true
            vc.row = (sender as! RowOf<Currencies>)
        }
    }
}
