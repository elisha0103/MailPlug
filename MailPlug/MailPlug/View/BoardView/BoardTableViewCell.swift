//
//  BoardTableViewCell.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import UIKit
import Combine

class BoardTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var viewModel: BoardTableCellViewModel? {
        didSet {
            bind()
            configureUI()
        }
    }
    
    var cancelBag = Set<AnyCancellable>()
    
    var badgeImageView: UIImageView =  {
       let imageView = UIImageView()
        imageView.setDimensions(width: 39, height: 20)
        
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        
        return label
    }()
    
    var fileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "Clip")
        imageView.setDimensions(width: 16, height: 16)
        
        return imageView
    }()
    
    var newBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NewBadge")
        imageView.setDimensions(width: 16, height: 13)
        
        return imageView
    }()
    
    var writerLabel: UILabel = {
        let label = UILabel()
        label.text = "w4efeifejikf"
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)

        return label
    }()
    
    var eyeImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "Eye")
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 16, height: 16)
        
        return imageView
    }()
    
    var viewCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1231"
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)

        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.$post
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.titleLabel.attributedText = viewModel.titleAttributedString
                self?.dateLabel.text = viewModel.timeStamp
                if post.isAnonymous {
                    self?.writerLabel.text = "익명"
                } else {
                    self?.writerLabel.attributedText = viewModel.writerAttributedString
                }
                self?.viewCountLabel.text = "\(post.viewCount)"
            }
            .store(in: &cancelBag)
        
    }
    
    func configureUI() {
        guard let viewModel = viewModel else { return }

        badgeImageView.image = nil
        if viewModel.post.hasReply { badgeImageView.image = UIImage(named: "ReplyBadge") }
        if viewModel.isNoticePost { badgeImageView.image = UIImage(named: "NoticeBadge") }
        
        badgeImageView.image == nil  ? (badgeImageView.isHidden = true) : (badgeImageView.isHidden = false)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let firstLineStack = UIStackView(arrangedSubviews: [badgeImageView,
                                                            titleLabel,
                                                            fileImageView,
                                                            newBadgeImageView])
        
        viewModel.isNewPost ? (newBadgeImageView.isHidden = false) : (newBadgeImageView.isHidden = true)
        viewModel.isIncludeAttachments ? (fileImageView.isHidden = false) : (fileImageView.isHidden = true)
        
//        titleLabel.attributedText = viewModel.titleAttributedString
        firstLineStack.axis = .horizontal
        firstLineStack.spacing = 3
        firstLineStack.distribution = .fill
        firstLineStack.alignment = .center
        
        writerLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        writerLabel.attributedText = viewModel.writerAttributedString
        let secondLineStack = UIStackView(arrangedSubviews: [writerLabel, dateLabel, eyeImage, viewCountLabel])
        
        secondLineStack.axis = .horizontal
        secondLineStack.spacing = 3
        secondLineStack.distribution = .fill
        secondLineStack.alignment = .center
        
        let cellStack = UIStackView(arrangedSubviews: [firstLineStack, secondLineStack])
        cellStack.axis = .vertical
        cellStack.alignment = .leading
        cellStack.spacing = -20
        cellStack.distribution = .fillEqually
        
        addSubview(cellStack)
        cellStack.centerY(inView: self)
        cellStack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                         paddingTop: 5, paddingLeft: 15, paddingRight: 15)
        
        print("configureUI done")
    }
    
}
