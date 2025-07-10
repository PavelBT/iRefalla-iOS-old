//
//  ImageCollectionViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import DKImagePickerController
import TKImageShowing

private let reuseIdentifier = "imageCell"

class ImageCollectionViewController: UICollectionViewController {
    
    var currentImages =  [Image]()
    private var newImages =  [Image]()
    private lazy var images = {
        return self.currentImages + self.newImages
    }
    lazy var imgs: [String] = {
        return self.images().map {$0.imagen?.url} as! [String]
    }()
    let tkImageVC = TKImageShowing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load bar items
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "guardarIcon") , style: .done, target: self, action: #selector(saveButton)), UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto)) ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))

        tkImageVC.images = imgs.toTKImageSource()

    }
    
    private func loadData() {
        newImages = Image.getLocalLabel(label: newItemsLabel)
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if newImages.isEmpty {
            loadData()
        }
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButton() {
        Image.pinAllLabel(objects: self.newImages, label: newItemsLabel)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addPhoto() {
        let pickerController = DKImagePickerController()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var i = 1
            for asset in assets {
                let localID = asset.localIdentifier
                self.newImages.append(Image(name:"imagen" + String(i),localID: localID ))
                i += 1
            }
            self.collectionView?.reloadData()
        }
        self.present(pickerController, animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images().count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let image = images()[indexPath.item]
        cell.image = image
        return cell
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row < imgs.count {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            self.tkImageVC.animatedView  = cell.imageView
            self.tkImageVC.currentIndex = indexPath.row
            self.present(self.tkImageVC, animated: true, completion: nil)
        }
    }
}
