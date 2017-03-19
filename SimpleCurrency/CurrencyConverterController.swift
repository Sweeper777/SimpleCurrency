import UIKit
import Eureka
import Alamofire
import SCLAlertView
import SwiftyJSON
import SwiftyUtils

class CurrencyConverterController: FormViewController {

    var shouldBeEmpty = true
    var currency1: Currencies!
    var currency2: Currencies!
    var rate: Double!
    var reverseRate: Double {
        return pow(rate, -1)
    }
    
    var formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.numberStyle = .decimal
        if shouldBeEmpty {
            form +++ LabelRow(tagNothing) {
                row in
                row.title = NSLocalizedString("Please select a currency!", comment: "")
            }
            return
        }
        form +++ LabelRow(tagToRate) {
            row in
            row.title = "1 \(currency1!) = \(formatter.string(from: rate as NSNumber)!) \(currency2!)"
        }
        
        <<< LabelRow(tagFromRate) {
            row in
            row.title = "1 \(currency2!) = \(formatter.string(from: reverseRate as NSNumber)!) \(currency1!)"
        }
        
        form +++ CurrencyConverterRow(tagCurrency1Convert) {
            row in
            row.title = "\(currency1.currencyCode) (\(currency1.symbol)):"
            row.cell.textField.placeholder = "0.00"
            row.cell.imageView!.image = UIImage(named: currency1.currencyCode)
            row.formatter = nil
        }
        .onChange {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency2Convert)!
                resultRow.cell.textField.text = self.formatter.string(from: (value * self.rate) as NSNumber)!
            }
        }
        .onEndEditing {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency2Convert)!
                resultRow.value = value * self.rate
            }
        }
        
        <<< CurrencyConverterRow(tagCurrency2Convert) {
            row in
            row.title = "\(currency2.currencyCode) (\(currency2.symbol)):"
            row.cell.textField.placeholder = "0.00"
            row.cell.imageView!.image = UIImage(named: currency2.currencyCode)
            row.formatter = nil
        }
        .onChange {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency1Convert)!
                print("\(value) * \(self.reverseRate) = \(value * self.reverseRate)")
                resultRow.cell.textField.text = self.formatter.string(from: (value * self.reverseRate) as NSNumber)!
            }
        }
        .onEndEditing {
            row in
            if let value = row.value {
                let resultRow: CurrencyConverterRow = self.form.rowBy(tag: tagCurrency1Convert)!
                resultRow.value = value * self.reverseRate
            }
        }
        
        tableView!.es_addPullToRefresh {
            [weak self] in
            self?.getRate {
                self?.reloadRates()
                self?.tableView?.es_stopPullToRefresh()
            }
        }
    }

    func getRate(completion: (() -> Void)?) {
        let url = "https://api.fixer.io/latest?base=\(currency1!)&symbols=\(currency2!)"
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
            
            if self != nil {
                if let rate = json["rates"][self!.currency2.currencyCode].double {
                    self?.rate = rate
                }
            }
            completion?()
        }
    }
    
    func reloadRates() {
        var row: LabelRow = form.rowBy(tag: tagToRate)!
        row.title = "1 \(currency1!) = \(rate!) \(currency2!)"
        row = form.rowBy(tag: tagFromRate)!
        row.title = "1 \(currency2!) = \(reverseRate) \(currency1!)"
        
        var resultRow: CurrencyConverterRow = form.rowBy(tag: tagCurrency1Convert)!
        resultRow.value = 0
        resultRow = form.rowBy(tag: tagCurrency2Convert)!
        resultRow.value = 0
        form.allRows.forEach { $0.updateCell() }
    }
}
