//
//  ToolsMenuViewController.swift
//  iReFalla
//
//  Created by Pavel on 31/01/17.
//  Copyright © 2017 Pavel. All rights reserved.
//

import UIKit
//import UXMPDFKit

private let reuseIdentifier = "menuCell"
private enum menuItem {
    case reporte, mapa, ucmEvent, ucmSOE, graficas, clima, zabbix, clientes, eventosMayores, dashboard, lineas
    
    func getParams() -> (segue: String, icon: UIImage) {
        switch self {
        case .reporte:
            return ("menuToreportes", #imageLiteral(resourceName: "reporteMenu"))
        case .mapa:
            return ("menuTomap", #imageLiteral(resourceName: "MapaMenu"))
        case .ucmEvent:
            return ("MenuToUcmEvents", #imageLiteral(resourceName: "ucmEventIconMenu"))
        case .ucmSOE:
            return ("menuToUcm", #imageLiteral(resourceName: "ucmIconMenu"))
        case .graficas:
            return ("MenuToEstadistica", #imageLiteral(resourceName: "graficasIconMenu"))
        case .clima:
            return ("MenuToWindy", #imageLiteral(resourceName: "climaIconMenu"))
        case .zabbix:
            return ("MenuToZabbix", #imageLiteral(resourceName: "zabbixMenu"))
        case .clientes:
            return ("menuToUsuarios", #imageLiteral(resourceName: "ClientesMenu"))
        case .eventosMayores:
            return ("MenuToEventosMayores", #imageLiteral(resourceName: "eventosMayoresMenu"))
        case .dashboard:
            return ("MenuToDashboard", #imageLiteral(resourceName: "dashboardIconMenu"))
        case .lineas:
            return ("MenuToLineas",#imageLiteral(resourceName: "circuitoIcon") )
        }
    }
}


class ToolsMenuViewController: UICollectionViewController {
    
    fileprivate let menu: [menuItem] = [.clientes, .reporte, .mapa, .eventosMayores, .lineas, .clima, .ucmEvent, .ucmSOE, .graficas, .zabbix]
    
    fileprivate var itemsRow:CGFloat {
        get {
            if UIDevice.current.orientation.isLandscape {
                return 3
            } else {return 2}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

     }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView?.reloadData()
    }
   
 
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return menu.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MenuCollectionViewCell
        let image = menu[indexPath.item].getParams().icon
        cell?.image.image = image
    
        return cell!
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let hardCodedPadding:CGFloat = 30
        let itemWidth = (collectionView.bounds.width / itemsRow) - hardCodedPadding
        let itemHeight:CGFloat = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        performSegue(withIdentifier: menu[index].getParams().segue, sender: self)
    }
}
