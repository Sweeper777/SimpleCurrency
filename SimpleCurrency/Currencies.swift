enum Currencies: String {
    case AUD = "AUD", BGN = "BGN", BRL = "BRL", CAD = "CAD", CHF = "CHF", CNY = "CNY", CZK = "CZK", DKK = "DKK", EUR = "EUR", GBP = "GBP", HKD = "HKD", HRK = "HRK", HUF = "HUF", IDR = "IDR", ILS = "ILS", INR = "INR", JPY = "JPY", KRW = "KRW", MXN = "MXN", MYR = "MYR", NOK = "NOK", PHP = "PHP", PLN = "PLN", RON = "RON", RUB = "RUB", SEK = "SEK", SGD = "SGD", THB = "THB", TRY = "TRY", USD = "USD", ZAR = "ZAR"
    
    var currencyCode: String {
        return "\(self)"
    }
    
    static var allValues: [Currencies] {
        return [.AUD, .BGN, .BRL, .CAD, .CHF, .CNY, .CZK, .DKK, .EUR, .GBP, .HKD, .HRK, .HUF, .IDR, .ILS, .INR, .JPY, .KRW, .MXN, .MYR, .NOK, .PHP, .PLN, .RON, .RUB, .SEK, .SGD, .THB, .TRY, .USD, .ZAR]
    }
    
    static var fullNameDict: [Currencies:String] {
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
    
    static var symbolDict: [Currencies:String] {
        return [
            .AUD: "$",
            .BGN: "лв",
            .BRL: "R$",
            .CAD: "$",
            .CHF: "CHF",
            .CNY: "¥",
            .CZK: "Kč",
            .DKK: "kr",
            .EUR: "€",
            .GBP: "£",
            .HKD: "$",
            .HRK: "kn",
            .HUF: "Ft",
            .IDR: "Rp",
            .ILS: "₪",
            .INR: "₹",
            .JPY: "¥",
            .KRW: "₩",
            .MXN: "$",
            .MYR: "RM",
            .NOK: "kr",
            .PHP: "₱",
            .PLN: "zł",
            .RON: "lei",
            .RUB: "₽",
            .SEK: "kr",
            .SGD: "$",
            .THB: "฿",
            .TRY: "₺",
            .USD: "$",
            .ZAR: "R",
        ]
    }
}
