import UIKit
import Eureka

class CurrencySelectorController: UITableViewController, TypedRowControllerType {
    typealias RowValue = Currencies
    
    var onDismissCallback: ((UIViewController) -> ())?
    var row: RowOf<Currencies>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Select a currency", comment: "")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Currencies.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = "\(Currencies.allValues[indexPath.row].currencyCode) (\(Currencies.symbolDict[Currencies.allValues[indexPath.row]]!))"
        cell.imageView!.image = UIImage(named: Currencies.allValues[indexPath.row].currencyCode)
        cell.detailTextLabel!.text = Currencies.allValues[indexPath.row].fullName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row.value = Currencies.allValues[indexPath.row]
        self.navigationController!.popViewController(animated: true)
        onDismissCallback?(self)
    }

}
