//
//  RestablecimientoTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 01/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

class RestablecimientoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitleLeftLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var restablecimientoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var causaLabel: UILabel!
    
    var restablecimiento: Restablecimiento? {
        didSet {
            loadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func loadData() {
        titleLabel?.text = restablecimiento?.relevador
        subtitleLabel?.text = restablecimiento?.equipo
        subtitleLeftLabel?.text = ""
        detailLabel?.text = restablecimiento?.observaciones
        restablecimientoLabel?.text = String(restablecimiento?.porcentajeDentro ?? 0)
        fechaLabel?.text = restablecimiento?.fecha?.toStringFormatter
        causaLabel?.text = "clientes actuales: \(restablecimiento?.usuarios ?? 0)"
    }

}
