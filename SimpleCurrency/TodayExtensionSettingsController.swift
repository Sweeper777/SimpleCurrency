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
    }
    
        }
    }
}
