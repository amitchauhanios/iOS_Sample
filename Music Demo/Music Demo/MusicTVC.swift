//
//  MusicTVC.swift
//  Advance Music Player
//
//  Created by Ongraph Technologies on 30/08/22.
//

import UIKit

class MusicTVC: UITableViewCell {

    @IBOutlet weak var numberLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var playingIMG: UIImageView!
    @IBOutlet weak var playIMG: UIImageView!
    var playCallBack :(()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func playBTN(_ sender: Any) {
        self.playIMG.isHidden = true
        self.playCallBack?()
    }
    
}
