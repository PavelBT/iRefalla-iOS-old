//
//  UCMEventTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

class UCMEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconViewImage: UIImageView!
    
    
    var ucmEvento: UcmEvent? {
        didSet {
            loadCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func loadCell() {
        if let ucmEvento = self.ucmEvento {
            // Title
            titleLabel?.text = "\(ucmEvento.equipo) \(ucmEvento.ramal ?? "")"
            detailLabel?.text = (ucmEvento.tipo ??  "") + " " +  (ucmEvento._protecciones ?? "") + " (" + String(ucmEvento._duracion) + " min)"
            detailLabel?.textColor = getColorCell()
            
            //subtitle
            timeStampLabel?.text = ucmEvento.ini_timestamp.toStringTimeStampFormatter
            
            iconViewImage?.image = loadIcon()
        }
    }
    
    private func loadIcon() -> UIImage? {
        let value = ucmEvento?.estado != "Cerrado" ? #imageLiteral(resourceName: "button_red"): #imageLiteral(resourceName: "button_green")
        return value
    }
    
    private func getColorCell() ->UIColor {
        return ucmEvento?.fin_timestamp != nil ? UIColor.black : UIColor.red
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
