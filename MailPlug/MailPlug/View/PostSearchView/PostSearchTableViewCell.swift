//
//  PostSearchTableViewCell.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/06.
//

import UIKit

class PostSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var category: SearchCategory? {
        didSet { configureUI() }
    }
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        
        return label
    }()
    
    var searchStringLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        return label
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configureUI() {
        guard let category = category else { return }
        categoryLabel.text = category.description
        addSubview(categoryLabel)
        categoryLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 15)
        addSubview(searchStringLabel)
        searchStringLabel.centerY(inView: self, leftAnchor: categoryLabel.rightAnchor, paddingLeft: 5)
    }

}
