//
//  ModalBoardsTableViewCell.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import UIKit

class ModalBoardsTableViewCell: UITableViewCell {

    // MARK: - Properties
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "post"
        
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        titleLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
