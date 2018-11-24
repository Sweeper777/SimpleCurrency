import UIKit
import Eureka

final class CurrencySelectorRow: SelectorRow<PushSelectorCell<Currencies>>, RowType {
    required init(tag: String?, _ initializer: ((CurrencySelectorRow) -> ())) {
        super.init(tag: tag)
        initializer(self)
        presentationMode = PresentationMode.segueName(segueName: "showCurrencySelector", onDismiss: nil)
//        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.storyBoard(storyboardId: "CurrencySelectorController", storyboardName: "Main", bundle: Bundle.main), onDismiss: {
//            _ in
//        })
        displayValueFor = {
            guard let currency = $0 else { return "" }
            return currency.currencyCode
        }
    }
    
    required convenience init(tag: String?) {
        self.init(tag, {_ in})
    }
}
