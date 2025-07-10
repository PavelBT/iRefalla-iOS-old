//
//  ZabbixMenuViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/12/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import UIKit

private let reuseIdentifier = "menuCell"
private enum menuItem {
    case host, eventos
    
    func getParams() -> (segue: String, icon: UIImage) {
        switch self {
        case .host:
            return ("ZabbixToHosts", #imageLiteral(resourceName: "hostsIconMenu"))
        case .eventos:
            return ("ZabbixToEvents", #imageLiteral(resourceName: "zabbixEventsIconMenu"))
        }
    }
}

class ZabbixMenuViewController: UICollectionViewController {
    
    fileprivate let menu: [menuItem] = [.host, .eventos]
   
    fileprivate var itemsRow:CGFloat {
        get {
            if UIDevice.current.orientation.isLandscape {
                return 3
            } else {return 2}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Zabbix"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        
    }
    
    @objc func dismissView () {
        dismiss(animated: true, completion: nil)
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
