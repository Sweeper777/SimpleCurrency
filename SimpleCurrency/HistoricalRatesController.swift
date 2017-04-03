import UIKit
import SwiftChart
import Alamofire
import SwiftyJSON
import SCLAlertView

class HistoricalRatesController: UITableViewController, ChartDelegate {
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
    @IBOutlet var sevenDayLabel: UILabel!
    @IBOutlet var thirtyDayLabel: UILabel!
    @IBOutlet var sevenDayLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var thirtyDayLeadingConstraint: NSLayoutConstraint!
    
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
        sevenDayChart.delegate = self
        thirtyDayChart.delegate = self
        getRate()
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }

    func getRate() {
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
                    return
                }
                
                let json = JSON(parseJSON: response.value!)
                if let _ = json["error"].string {
                    return
                }
                
                if self != nil {
                    if let rate = json["rates"][self!.currency.currencyCode].double {
                        self!.rates[date] = rate
                    }
                }
            }
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
            if dataArray.count == 7 {
                chart.xLabels = Array(stride(from: 0.0, to: Float(dataArray.count), by: 1))
            } else {
                chart.xLabels = Array(stride(from: 0.0, to: Float(dataArray.count), by: 5))
            }
            chart.xLabelsFormatter = { index, _ in
                let formatter = DateFormatter()
                formatter.timeStyle = .none
                formatter.dateFormat = "dd/MM"
                if dataArray.count == 7 {
                    return formatter.string(from: self.last7Days[index])
                } else {
                    return formatter.string(from: self.last30Days[index * 5])
                }
            }
            chart.labelFont = UIFont.systemFont(ofSize: 10)
            chart.setNeedsDisplay()
        }
        
        refresh(chart: thirtyDayChart, with: rates.map{$0}.sorted{$0.0 < $1.0}.map{Float($0.value)})
        refresh(chart: sevenDayChart, with: last7DaysRates.map{$0}.sorted{$0.0 < $1.0}.map{Float($0.value)})
    }
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        var label: UILabel
        var labelLeadingMarginConstraint: NSLayoutConstraint
        var days: [Date]
        if chart == thirtyDayChart {
            label = thirtyDayLabel
            days = last30Days
            labelLeadingMarginConstraint = thirtyDayLeadingConstraint
        } else {
            label = sevenDayLabel
            days = last7Days
            labelLeadingMarginConstraint = sevenDayLeadingConstraint
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            label.isHidden = false
            let labelLeadingMarginInitialConstant = CGFloat(0)
            label.text = "\(formatter.string(from: days[indexes[0]!])): \(value)"
            
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            
            labelLeadingMarginConstraint.constant = constant
            
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        if chart == thirtyDayChart {
            thirtyDayLabel.isHidden = true
        } else {
            sevenDayLabel.isHidden = true
        }
    }
}
