import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController {
    var currency: Currencies!
    var rates: [Date: Double] = [:]
        {
        didSet {
            if rates.count == 30 {
                refreshCharts()
            }
        }
    }
    
    @IBOutlet var sevenDayChart: Chart!
    @IBOutlet var thirtyDayChart: Chart!
    
    let last30Days: [Date] = {
        var dates = [Date]()
        for i in 0...29 {
            let day = Date().date.addingTimeInterval(Double(-60 * 60 * 24 * (29 - i)))
            dates.append(day)
        }
        
        return dates
    }()
    
    var last7Days: [Date] {
        return Array(last30Days.dropFirst(23))
    }
    
    var last7DaysRates: [Date: Double] {
        var rates = [Date: Double]()
        for date in last7Days {
            rates[date] = self.rates[date]
        }
        return rates
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRate(completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }

    func getRate(completion: (() -> Void)?) {
        let baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for date in last30Days {
            let dateString = formatter.string(from: date)
            let url = "https://api.fixer.io/\(dateString)?base=\(baseCurrency!)&symbols=\(currency!)"
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
                    if let rate = json["rates"][self!.currency.currencyCode].double {
                        self!.rates[date] = rate
                    }
                }
            }
            completion?()
        }
    }
    
    func refreshCharts() {
        func refresh(chart: Chart, with dataArray: [Float]) {
            let data = ChartSeries(dataArray)
            data.area = false
            chart.add(data)
            let min = dataArray.min()!
            let max = dataArray.max()!
            let range = max - min
            let order = ceil(log(Double(range)) / M_LN10)
            let delta = Float(pow(10.0, order) * 0.1)
            chart.minY = min - delta  < 0 ? 0 : min - delta
            chart.maxY = max + delta
            chart.yLabels = Array(stride(from: chart.minY!, through: chart.maxY!, by: (chart.maxY! - chart.minY!) / 10))
            chart.yLabelsFormatter = { _, float in return float.description }
            chart.setNeedsDisplay()
        }
        
        refresh(chart: thirtyDayChart, with: rates.map{$0}.sorted{$0.0 < $1.0}.map{Float($0.value)})
        refresh(chart: sevenDayChart, with: last7DaysRates.map{$0}.sorted{$0.0 < $1.0}.map{Float($0.value)})
    }
}
