import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.SimpleCurrencyGroup")!
    }
}
