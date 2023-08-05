//
//  SearchResultTableViewCell.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/06.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
