//
//  ConfiguracionTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 31/10/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit
import Parse
import DKImagePickerController

class ConfiguracionTableViewController: UITableViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var carreteSwitchButton: UISwitch!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    private var cache = URLCache(memoryCapacity: 100*1024*1024, diskCapacity: 500*1024*1024, diskPath: "mapTileCache")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = 60
        userImageView.clipsToBounds = true
        loadData()

    }
    
    private func loadData() {
        // IMAGE
        currentUser?.fetchInBackground(block: { (user, error) in
            if error == nil {
                if let image = user?["imagen"] as? PFFileObject {
                    image.getDataInBackground { (data, error) in
                        if error == nil, let data = data {
                            self.userImageView?.image = UIImage(data: data)
                        }
                    }
                }
            }
        })
        
        usernameLabel?.text = currentUser?.username
        versionLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        cacheLabel?.text = String(cache.currentDiskUsage / 1048576) + " MB"
        let lastUpdate = UserDefaults.standard.object(forKey: "lasUpdateDB") as? Date
        lastUpdateLabel?.text = lastUpdate?.toStringFormatter ?? "nunca"
    }

    @IBAction func userImageButton(_ sender: Any) {
        let pickerController = DKImagePickerController()
        pickerController.allowMultipleTypes = false
        pickerController.singleSelect = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            let asset = assets.first
            let localID = asset?.localIdentifier
            Image.getLocalImage(withLocalIdentifier: localID!, maxPixels: 200, completion: { (image) in
                if let image = image {
                    let imageData = image.jpegData(compressionQuality: 0.8)
                    currentUser?["imagenData"] = imageData
                    currentUser?.saveEventually()
                    self.userImageView?.image = image
                }
            })
            
            self.tableView?.reloadData()
        }
        self.present(pickerController, animated: true)
    }
    
    
    @IBAction func carreteSwitchButton(_ sender: Any) {
        
    }
    
    @IBAction func cacheButton(_ sender: Any) {
        cache.removeAllCachedResponses()
        cacheLabel?.text = "0 MB"
        tableView.reloadData()
    }
    
    @IBAction func logOut(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    // MARK: - Table view data source

}
