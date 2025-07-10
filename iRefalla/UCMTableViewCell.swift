//
//  UCMTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/02/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

class UCMTableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconViewImage: UIImageView!
    
    var ucmEvento: UcmSOE? {
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
            titleLabel?.text = "\(ucmEvento.path1 ?? "") \(ucmEvento.path3 ?? "")"
            detailLabel?.text = ucmEvento.text
            detailLabel?.textColor = getColorCell()
            
            //subtitle
            timeStampLabel?.text = ucmEvento.timeStamp
            
            iconViewImage?.image = loadIcon()
        }
    }

    private func loadIcon() -> UIImage? {
        let value = Bool(truncating: ucmEvento?.value ?? 0)
        switch ucmEvento?.tipo {
        case .some(.CT), .some(.CB):
            return value ? #imageLiteral(resourceName: "button_red"): #imageLiteral(resourceName: "button_green")
        case .some(.CPR):
            return #imageLiteral(resourceName: "button_yellow")
        case .some(.PR):
            return #imageLiteral(resourceName: "fuseIcon")
        default:
            return #imageLiteral(resourceName: "alarmaIcon")
        }
    }
    
    private func getColorCell() ->UIColor {
        switch ucmEvento?.tipo {
        case .some(.PR), .some(.CT):
            return UIColor.red
        case .some(.AL):
            return UIColor.darkGray
        default:
            return UIColor.black
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
