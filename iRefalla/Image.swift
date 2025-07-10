//
//  Image.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse
import Photos

fileprivate let maxImagePixels = 1200
fileprivate let maxThumbnailPixels = 200
fileprivate let imageCompression: CGFloat = 0.8

class Image: PFObject {
    
    enum imageType {
        case imagen, thumbnail
    }
    
    @NSManaged var fecha: Date?
    @NSManaged var registro: RegistroCNN?
    @NSManaged var id_cnn: String?
    @NSManaged var usuario: PFUser?
    @NSManaged var userName: String?
    @NSManaged var thumbnail: PFFileObject?
    @NSManaged var imagen: PFFileObject?
    @NSManaged var archivo: Data?
    var localID: String?
    
    override init() {
        super.init()
    }
    
    init(name: String, localID: String) {
        super.init()
        self.usuario = currentUser
        self.userName = currentUser?.username
        self.localID = localID
        self.fecha = Date()
        setImage(localID: localID, name: name)
    }
    
    func getImage(image: @escaping (UIImage?) ->Void) {
        getImageHanler(type: .imagen) { (data) in
            image(data)
        }
    }
    
    func getThumbnail(image: @escaping (UIImage?) ->Void) {
        getImageHanler(type: .thumbnail) { (data) in
            image(data)
        }
    }
    
    private func setImage(localID: String, name: String) {
        Image.getLocalImage(withLocalIdentifier: localID , maxPixels: maxImagePixels) { (image) in
            if let image = image {
                let data = image.jpegData(compressionQuality: imageCompression)
                self.archivo = data
//                self.imagen = PFFile(name: name, data: data!)
            }
        }
    }
    
    private func getImageHanler(type: imageType, image: @escaping (UIImage?) ->Void) {
        let max: Int? = type == .thumbnail ? maxThumbnailPixels : nil
        if let local = self.localID {
            Image.getLocalImage(withLocalIdentifier: local, maxPixels: max) { (data) in
                if let data = data {
                    image(data)
                } else {
                    image(nil)
                }
            }
        } else if (type == .imagen) {
            self.imagen?.getDataInBackground(block: { (data, error) in
                if error == nil, let data = data {
                    image(UIImage(data: data))
                } else {
                    print(error?.localizedDescription as Any)
                    image(nil)
                }
            })
        } else {
            self.thumbnail?.getDataInBackground(block: { (data, error) in
                if error == nil, let data = data {
                    image(UIImage(data: data))
                } else {
                    print(error?.localizedDescription as Any)
                    image(nil)
                }
            })
        }
    }
    

    static func getLocalImage(withLocalIdentifier id: String, maxPixels: Int? = nil,completion: @escaping (UIImage?) -> Void) {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        let manager = PHImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        guard let asset = assets.firstObject else { return }
        let w = asset.pixelWidth
        let h = asset.pixelHeight
        if let maxPixels = maxPixels, maxPixels < max(w, h) {
            let size = imageScale(w: w, h: h, maxPixel: maxPixels)
            manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                if let data = image {
                    completion(data)
                }
            })
        } else {
            manager.requestImageData(for: asset, options: options) { (data, name, orient, info) in
                if let data = data {
                    completion(UIImage(data: data))
                }
            }
        }
    }
    
    static private func imageScale(w: Int, h: Int, maxPixel: Int) -> CGSize  {
        let max = w >= h ? w : h
        let scale: CGFloat = CGFloat(maxPixel)/CGFloat(max)
        let width = CGFloat(w) * scale
        let heigth = CGFloat(h) * scale
        return CGSize(width: width, height: heigth)
    }
}

extension Image: PFSubclassing {
    static func parseClassName() -> String {
        return "Imagenes"
    }
}

extension Image: ParseManager, ParseLocalManager {

    static var storePolicy: storePolicy {
        return .onlyNetwork
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "createdAt", ascending: true)]
    }
}
