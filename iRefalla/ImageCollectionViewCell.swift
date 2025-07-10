//
//  ImageCollectionViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import Parse
import TKImageShowing

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var image: Image? {
        didSet {
            image?.getThumbnail(image: { (thumb) in
                self.imageView?.image = thumb
            })
            if let usuario = image?.userName {
                let fecha = image?.createdAt?.toStringFormatter ?? "Ahora"
                titleLabel?.text = usuario + " @ " + fecha
            }
        }
    }
}
