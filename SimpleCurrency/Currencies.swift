enum Currencies : CustomStringConvertible {
    case AUD, BGN, BRL, CAD, CHF, CNY, CZK, DKK, GBP, HKD, HRK, HUF, IDR, ILS, INR, JPY, MRW, MXN, MYR, NOK, PHP, PLN, RON, RUB, SEK, SGD, THB, TRY, USD, ZAR, EUR
    
    var description: String {
        return "\(self)"
    }
    
    static var allValues: [Currencies] {
        return [.AUD, .BGN, .BRL, .CAD, .CHF, .CNY, .CZK, .DKK, .GBP, .HKD, .HRK, .HUF, .IDR, .ILS, .INR, .JPY, .MRW, .MXN, .MYR, .NOK, .PHP, .PLN, .RON, .RUB, .SEK, .SGD, .THB, .TRY, .USD, .ZAR, .EUR]
    }
}
