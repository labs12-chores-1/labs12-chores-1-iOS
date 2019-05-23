//
//  CommentTableViewCell.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/23/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class CommentTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var commentedByLabel: UILabel!
    @IBOutlet weak var commentStringLabel: UILabel!
    @IBOutlet weak var commentedOnLabel: UILabel!
    
}
