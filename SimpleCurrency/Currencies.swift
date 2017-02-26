enum Currencies {
    case AUD, BGN, BRL, CAD, CHF, CNY, CZK, DKK, EUR, GBP, HKD, HRK, HUF, IDR, ILS, INR, JPY, KRW, MXN, MYR, NOK, PHP, PLN, RON, RUB, SEK, SGD, THB, TRY, USD, ZAR
    
    var currencyCode: String {
        return "\(self)"
    }
    
    static var allValues: [Currencies] {
        return [.AUD, .BGN, .BRL, .CAD, .CHF, .CNY, .CZK, .DKK, .EUR, .GBP, .HKD, .HRK, .HUF, .IDR, .ILS, .INR, .JPY, .KRW, .MXN, .MYR, .NOK, .PHP, .PLN, .RON, .RUB, .SEK, .SGD, .THB, .TRY, .USD, .ZAR]
    }
    
    var fullNameDict: [Currencies:String] {
        return [
            .AUD: "Australian Dollar",
            .BGN: "Bulgarian Lev",
            .BRL: "Brazilian Real",
            .CAD: "Canadian Dollar",
            .CHF: "Swiss Franc",
            .CNY: "Yuan Renminbi",
            .CZK: "Czech Koruna",
            .DKK: "Danish Krone",
            .EUR: "Euro",
            .GBP: "Pound Sterling",
            .HKD: "Hong Kong Dollar",
            .HRK: "Croatian Kuna",
            .HUF: "Hungarian Forint",
            .IDR: "Indonesian Rupiah",
            .ILS: "Israeli New Shekel",
            .INR: "Indian Rupee",
            .JPY: "Japanese Yen",
            .KRW: "Korean Won",
            .MXN: "Mexican Nuevo Peso",
            .MYR: "Malaysian Ringgit",
            .NOK: "Norwegian Krone",
            .PHP: "Philippine Peso",
            .PLN: "Polish Zloty",
            .RON: "Romanian New Leu",
            .RUB: "Russian Ruble",
            .SEK: "Swedish Krona",
            .SGD: "Singapore Dollar",
            .THB: "Thai Baht",
            .TRY: "Turkish Lira",
            .USD: "US Dollar",
            .ZAR: "South African Rand",
        ]
    }
}
