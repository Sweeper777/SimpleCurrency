import UIKit
import Eureka

class CurrencySelectorController: UITableViewController, TypedRowControllerType {
    typealias RowValue = Currencies
    
    var onDismissCallback: ((UIViewController) -> ())?
    var row: RowOf<Currencies>!
    var allowNilValue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Select a currency", comment: "")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Currencies.allCases.count + (allowNilValue ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if allowNilValue {
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("None", comment: "")
                cell.detailTextLabel?.text = ""
                return cell
            } else {
                cell.textLabel!.text = "\(Currencies.allCases[indexPath.row - 1].currencyCode) (\(Currencies.allCases[indexPath.row - 1].symbol))"
                cell.imageView!.image = UIImage(named: Currencies.allCases[indexPath.row - 1].currencyCode)
                cell.detailTextLabel!.text = Currencies.allCases[indexPath.row - 1].fullName
                return cell
            }
        } else {
            cell.textLabel!.text = "\(Currencies.allCases[indexPath.row].currencyCode) (\(Currencies.allCases[indexPath.row].symbol))"
            cell.imageView!.image = UIImage(named: Currencies.allCases[indexPath.row].currencyCode)
            cell.detailTextLabel!.text = Currencies.allCases[indexPath.row].fullName
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row.value = Currencies.allValues[indexPath.row]
        self.navigationController!.popViewController(animated: true)
        onDismissCallback?(self)
    }

}
