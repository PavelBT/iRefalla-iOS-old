//
//  CNNTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 20/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import MRProgress
import PDFKit
import Parse

let newItemsLabel = "newObjects" //label para pin los objetos a guardar

class CNNTableViewController: UITableViewController {
    
    private var registrosFallas: [RegistroCNN]?
    private var registrosFallasFiltred: [RegistroCNN]?
    private var searchController = UISearchController(searchResultsController: nil)
    private var limit: Int = 50
    private var page: Int? = 0
    private var filterParams: [queryParams]?
    var circuito: Circuito?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Title y filtro
        if let circuito = circuito?.clave {
            self.title = circuito
            //filter para circuito
            self.filterParams = [queryParams("cveCircuito", circuito, .equal)]
            navigationItem.rightBarButtonItems?[0].isEnabled = false // DESABILITAR EL RELOAD EN LA CONSUTAL DE HISTORIAL
        } else {
            self.title = "Registros de CNN"
        }

        // observer for reload data
        NotificationCenter.default.addObserver(self, selector: #selector(CNNTableViewController.reloadButton(_:)), name: NSNotification.Name(rawValue: "reloadCNN"), object: nil)
        loadData()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchBarLoad(searchController: searchController, placeholder: "Subestacion, Circuito", ScopeTitles: ["Todo", ">5 min", "<5 min"])
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationBar.backgroundColor = navBarColor
        } else {
            // Fallback on earlier versions
        }
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // check for update avaible

        self.checkUpdates()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // BORRA ANTERIORES CARGAS
        Mensaje.unPinAllLabel(label: newItemsLabel)
        
    }
    
    @objc func loadData(page: Int = 0) {
        loadActivityIndicator(title: "Cargando")
        RegistroCNN.getFilter(limit:self.limit, page: page, filter: self.filterParams) { (data) in
            if let data = data, data.count > 0 {
                if page == 0 {
                    self.registrosFallas =  data
                } else {
                    self.registrosFallas = self.registrosFallas! + data
                }
                self.tableView.endUpdates()
                GlobalMainQueue.async {
                    self.dismissActivityIndicator()
                    self.tableView.reloadData()
                }
            } else {
                self.page = nil
                self.dismissActivityIndicator()
            }
        }

    }
    
    private func autoupdateViewData() {
        
    }
 
    @objc private func checkUpdates() {
        
        // UPDATE DATABASE IF NEEDED
        PFConfig.getInBackground { (config, error) in
            if error == nil, let config = config {
                let lastServerUpdate =  config["lastUpdateDB"] as? Date ?? Date(timeIntervalSince1970: 0)
                let lastLocalUpdate = UserDefaults.standard.value(forKey: "lastUpdateDB") as? Date ?? Date(timeIntervalSince1970: 0)
                print("last local update DB", lastLocalUpdate)
                if lastLocalUpdate <= lastServerUpdate {
                    PFObject.unpinAllObjectsInBackground()
                    Subestacion.updateLocalDB { (success1) in
                        if success1 {
                            print(Date(), "Base de datos Subestaciones update ok")
                            Circuito.updateLocalDB(success: { (success2) in
                                if success2 {
                                    print(Date(), "Base de datos Circuitos update ok")
                                    Causa.updateLocalDB(success: { (success3) in
                                        if success3 {
                                            print(Date(), "Base de datos Causas update ok")
                                            UserDefaults.standard.set(Date(), forKey: "lastUpdateDB")
                                        }
                                    })
                                }
                            })
                        }
                    }
                }
            }
        }
    }
   
    
    @IBAction func reloadButton(_ sender: Any) {
        
        self.page = 0
        self.filterParams = nil
        goToTop()
        self.loadData()
    }
    
    @IBAction func actionButton(_ sender: UIBarButtonItem) {
        if let indexes = tableView.indexPathsForSelectedRows, indexes.count > 0 {
            var selectRegistros = [RegistroCNN]()
            for index in indexes {
                selectRegistros.append(selectedRegistro(index: index.row))
            }
            RegistroCNN.actionMenu(viewController: self, registros: selectRegistros)
        }
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    private func goToTop() {
        if let count = self.registrosFallas?.count, count > 0 {
            self.tableView?.scrollToRow(at:  IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchBarActive {
            return registrosFallasFiltred?.count ?? 0
        } else {
            return registrosFallas?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let row = selectedRegistro(index: index)
        
        var cellID = "CNNCell"
        if row._atendido {
            cellID = "FallaCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CNNTableViewCell
        cell?.delegate = self
        cell?.registro = row
        
        
        if registrosFallas!.count >= self.limit, index == registrosFallas!.count-1, page != nil {
            self.page! += 1
            loadData(page: page!)
        }
        return cell!
    }

    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, sucess) in
            let row = self.selectedRegistro(index: indexPath.row)
            self.filterParams = [queryParams("cveSubestacion", row.cveSubestacion, .equal )]
            self.filterParams?.append(queryParams("cveCircuito", row.cveCircuito, .equal))
            self.filterParams?.append(queryParams("cveLinea", row.cveLinea, .equal))
            
            self.page = 0
            
            tableView.beginUpdates()
            self.goToTop()
            self.loadData()
            tableView.endUpdates()
        }
        action.image = #imageLiteral(resourceName: "filtroFill")
        action.backgroundColor = UIColor.blue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CNNToFalla" {
            let index = self.tableView.indexPathForSelectedRow?.row
            let row = selectedRegistro(index: index!)
            if let destination = segue.destination as? ConsultaViewController {
                destination.registro = row
            }
            if let destination = segue.destination as? CargaFallaTableViewController {
                destination.registro = row
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CNNToFalla" {
            return !tableView.isEditing
        }
        return true
    }
    
}

extension CNNTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    func selectedRegistro(index: Int) -> RegistroCNN {
        var row: RegistroCNN!
        if searchBarActive {
            row = registrosFallasFiltred?[index]
        } else {
            row = registrosFallas?[index]
        }
        return row
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String = "Todo") {
        registrosFallasFiltred = registrosFallas?.filter({ (registro) -> Bool in
            let text = searchBarText.lowercased()
            let subestacion = registro._subestacion.lowercased()
            let circuito = registro._circuito.lowercased()
            var scopeMatch: Bool = false
            switch scope {
                case "Todo": scopeMatch = true
            case ">5 min": if registro._duracion >= 5 {scopeMatch = true}
            case "<5 min": if registro._duracion < 5 {scopeMatch = true}
            default: break
            }
            return scopeMatch && ((subestacion.contains(text) || circuito.contains(text)) || text == "")
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.endEditing(true)
        filterContentForSearchText(searchBarText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBarText: searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
    }
    
}


extension RegistroCNN {
    static func actionMenu (viewController: UIViewController, registros: [RegistroCNN]) {
        
        let verMapa = UIAlertAction(title: "Ver en Mapa", style: .default) { (alert) in
            let circuitos = registros.map {$0._circuito}
            let navcon = ActionMenuloadMap(circuitos: circuitos, fallas: nil)
            viewController.present(navcon, animated: false, completion: nil)
        }
        let compartir = UIAlertAction(title: "Compartir en...", style: .default) { (alert) in
            let share = registros.map {$0._shareObject}.flatMap {$0}  as [AnyObject]
            let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
            viewController.present(vc, animated: true, completion: {
                vc.viewDidLoad()
            })
        }
        
        let fallasMap = UIAlertAction(title: "Mostrar las falllas", style: .default) { (alert) in
            let circuitos = registros.map {$0._circuito}
            let fallas = registros.map {$0._fallaAnnotation}.filter {$0 != nil} as? [FallaAnnotation]
            let navcon = ActionMenuloadMap(circuitos: circuitos, fallas: fallas)
            viewController.present(navcon, animated: false, completion: nil)
        }
        
        var actions = [verMapa, compartir, fallasMap]
        if registros.count == 1, let registro = registros.first {
            let notaInicial = UIAlertAction(title: "Nota incial", style: .default) { (alert) in
                registro.getNota(tipo:"notaInicial", completition: { (nota) in
                    let share =   [nota] as [AnyObject]
                    let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
                    viewController.present(vc, animated: true, completion: {
                        vc.viewDidLoad()
                    })
                })
            }
            actions.append(notaInicial)
            
            let notaCompleta = UIAlertAction(title: "Nota completa", style: .default) { (alert) in
                registro.getNota(tipo:"notaCompleta", completition: { (nota) in
                    let share =   [nota] as [AnyObject]
                    let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
                    viewController.present(vc, animated: true, completion: {
                        vc.viewDidLoad()
                    })
                })
            }
            actions.append(notaCompleta)
        }
        
        AlertDialog.ShowAlert(viewController: viewController, title: "Selecciona la Accion", message: nil, actions: actions, fields: nil, completion: nil)
    }
    
    static private func ActionMenuloadMap(circuitos: [String]?, fallas: [FallaAnnotation]?) -> UINavigationController {
        let mapviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
        mapviewVC.circuitos = circuitos
        mapviewVC.fallasAnnotation = fallas
        return UINavigationController(rootViewController: mapviewVC)
    }
}

extension CNNTableViewController: UsuariosButtonProtocol {
    func click(circuito: Circuito?) {
        if let circuito = circuito {
            //mostrar usuarios importanntes
            let params = [queryParams("circuito", circuito, .equal)]
            let uiController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsuariosImpVC") as! UsuariosImportantesTableViewController
            uiController.filter = params
            let navcon = UINavigationController(rootViewController: uiController)
            self.present(navcon, animated: false, completion: nil)
        }
    }
    
}
