import UIKit
import Eureka

final class CurrencyConverterCell: DecimalCell {
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if let row = self.row as? CurrencyConverterRow {
            row.onEndEditingCallback?(row)
        }
    }
}

final class CurrencyConverterRow: FieldRow<CurrencyConverterCell>, RowType {
    fileprivate var onEndEditingCallback: ((CurrencyConverterRow) -> ())?
    public func onEndEditing(_ callback: @escaping (CurrencyConverterRow) -> ()) -> CurrencyConverterRow {
        onEndEditingCallback = callback
        return self
    }
    
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        formatter = numberFormatter
    }
}
