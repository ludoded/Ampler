//
//  ChartsViewController.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit
import Charts

final class ChartsViewController: UIViewController {
    private var model: ChartsModel!
    
    @IBOutlet fileprivate weak var chartView: BarChartView!
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    
    @IBAction fileprivate func segmentedToggle(_ sender: Any) {
        setData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = ChartsModel()
        setupCharts()
    }
    
    private func setupCharts() {
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 7 // Weekly
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularityEnabled = true
        xAxis.granularity = 86400
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter()
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        
        setData()
    }
    
    private func setData() {
        let data = model.dataForChart(forMetric: DistanceMetric(rawValue: segmentedControl.selectedSegmentIndex)!)
        chartView.data = data
        chartView.setVisibleXRangeMaximum(86400 * 7) //week
    }
}

extension ChartsViewController: ChartViewDelegate {
    
}


class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        let date = Date(timeIntervalSince1970: value)
        return formatter.string(from: date)
    }
}
