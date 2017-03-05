import UIKit
import Eureka

class CurrencySelectorRow: SelectorRow<PushSelectorCell<Currencies>, CurrencySelectorController>, RowType {
    required init(tag: String?, _ initializer: ((CurrencySelectorRow) -> ())) {
        super.init(tag: tag)
        initializer(self)
        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.storyBoard(storyboardId: "CurrencySelectorController", storyboardName: "Main", bundle: nil), onDismiss: {
            _ in
        })
        displayValueFor = {
            guard let currency = $0 else { return "" }
            return currency.currencyCode
        }
    }
    
    required convenience init(tag: String?) {
        self.init(tag: tag)
    }
}
