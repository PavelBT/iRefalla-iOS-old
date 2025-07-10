//
//  MessageCollectionViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let grayBubbleImage = UIImage(named:"bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named:"bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    var message: Mensaje? {
        didSet {
            messageTextView?.text = message?.texto?.uppercased() ?? ""
            userLabel?.text = message?.userName ?? ""
            dateLabel?.text = message?.fecha?.toStringFormatter
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
