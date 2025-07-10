//
//  EstadisticaViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 6/7/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import UIKit
import Charts

fileprivate let cellName = "cell"

class EstadisticaViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var tableView: UITableView!
    
    private var estadisticaZonasMes: [[String: AnyObject]]?
    private var estadisticaZonasTrimestre: [[String: AnyObject]]?
    private var estadisticaZonasAno: [[String: AnyObject]]?
    
    private var arrayTop: [EventosCircuitos]?
    private var mesTop: [EventosCircuitos]?
    private var trimestreTop: [EventosCircuitos]?
    private var anoTop: [EventosCircuitos]?
    private let limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .done, target: self, action: #selector(dismissVC))
        
        configureChartView()
        
        loadData()
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loadData() {
        
        // ESTADISTICA DE ZONA
        EventosCircuitos.getEventosByZonas(periodo: EventosCircuitos.periodoEventos.mes) { (data) in
            self.estadisticaZonasMes = data
            self.loadBarChart(data: data)
        }
        
        EventosCircuitos.getEventosByZonas(periodo: EventosCircuitos.periodoEventos.trimestre) { (data) in
            self.estadisticaZonasTrimestre = data
        }
        
        EventosCircuitos.getEventosByZonas(periodo: EventosCircuitos.periodoEventos.anoMovil) { (data) in
            self.estadisticaZonasAno = data
        }
        
        // TOP CIRCUITOS
        EventosCircuitos.getTopCircuitosEventos(limit: limit, periodo: EventosCircuitos.periodoEventos.mes) { (top) in
            self.mesTop = top
            self.arrayTop = top
            GlobalMainQueue.async {
                self.tableView.reloadData()
            }
        }
        EventosCircuitos.getTopCircuitosEventos(limit: limit, periodo: EventosCircuitos.periodoEventos.trimestre) { (top) in
            self.trimestreTop = top
        }
        
        EventosCircuitos.getTopCircuitosEventos(limit: limit, periodo: EventosCircuitos.periodoEventos.anoMovil) { (top) in
            self.anoTop = top
        }
        
    }
    
    private func configureChartView() {
        // CONFIGURE
        
        barChartView.noDataText = "Descargando datos"
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.gridLineWidth = 0
        barChartView.xAxis.axisLineWidth = 0
        
    }
    
    private func loadBarChart(data: [[String: AnyObject]]?) {
        if let estadisticas = data {
            var dataEntriesPer = [BarChartDataEntry]()
            var dataEntriesTran = [BarChartDataEntry]()
            
            let zonas = estadisticas.map {$0["zona"] as? String ?? ""}
            let zonaAxis = ZonaAxis(labels: zonas)
            
            for (ind, value) in estadisticas.enumerated() {
                let per = Double(value["permanente"] as? Int ?? 0)
                let index = Double(ind)
                let dataEntry = BarChartDataEntry(x: Double(index), y: per)
                dataEntriesPer.append(dataEntry)
                _ = zonaAxis.stringForValue(index, axis: barChartView.xAxis)
            }
            
            barChartView.xAxis.valueFormatter = zonaAxis
            
            for (index, value) in estadisticas.enumerated() {
                let tran = Double(value["transitorio"] as? Int ?? 0)
                let dataEntry = BarChartDataEntry(x: Double(index), y: tran)
                dataEntriesTran.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntriesPer, label: "permantente")
            let chartDataSet2 = BarChartDataSet(entries: dataEntriesTran, label: "transitorio")
            chartDataSet.colors = [UIColor(hex: 0xF26627, alpha: 1)]
            chartDataSet.valueColors = [UIColor.white]
            chartDataSet2.colors = [UIColor(hex: 0x3E4651, alpha: 1)]
            let chartData = BarChartData(dataSets: [chartDataSet2, chartDataSet])
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximumFractionDigits = 0
            formatter.multiplier = 1.0
            chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
            
            barChartView.data = chartData
            barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
    }
    
    
    @IBAction func periodoChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.arrayTop = mesTop
            loadBarChart(data: estadisticaZonasMes)
        case 1:
            self.arrayTop = trimestreTop
            loadBarChart(data: estadisticaZonasTrimestre)
        case 2:
            self.arrayTop = anoTop
            loadBarChart(data: estadisticaZonasAno)
        default:
            break
        }
        GlobalMainQueue.async {
            self.tableView.reloadData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EstadisticaViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.arrayTop?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        let row = arrayTop?[indexPath.row]
        
        cell.textLabel?.text = "\(indexPath.row + 1) - \(row?.circuito ?? "")"
        cell.detailTextLabel?.text = row?._eventosResumen
        
        return cell
    }
}


class ZonaAxis: NSObject, AxisValueFormatter {
    var labels: [String]!
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }
    
}
