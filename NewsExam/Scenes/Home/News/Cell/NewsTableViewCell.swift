//
//  NewsTableViewCell.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import UIKit
import SnapKit
import Kingfisher
import SkeletonView

class NewsTableViewCell: UITableViewCell {
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.silver
        imageView.isSkeletonable = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium(size: 17)
        label.textColor = Colors.metallicSeaweed
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.isSkeletonable = true
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular(size: 14)
        label.textColor = Colors.black
        label.textAlignment = .center
        label.numberOfLines = 6
        label.skeletonTextNumberOfLines = 4
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.isSkeletonable = true
        return label
    }()
    
    private let updatedDateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular(size: 12)
        label.textColor = Colors.silver
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.isSkeletonable = true
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.silver.withAlphaComponent(0.2)
        view.isSkeletonable = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard selected else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setSelected(false, animated: true)
        }
    }
    
    private func setupViews() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        selectionStyle = .gray
        [newsImageView, titleLabel, contentLabel, updatedDateLabel, lineView].forEach {
            contentView.addSubview($0)
        }
        
        newsImageView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.width.equalTo(contentView.snp.width).dividedBy(1.75)
            make.height.equalTo(newsImageView.snp.width).multipliedBy(9.0 / 16.0)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(newsImageView.snp.bottom).offset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        updatedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(updatedDateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview().priority(999)
        }
    }
    
    func setData(_ model: News) {
        newsImageView.kf.setImage(with: URL(string: model.urlToImage ?? ""), placeholder: nil, options: nil)
        titleLabel.text = model.title
        contentLabel.text = model.content
        updatedDateLabel.text = model.publishedAt
    }
}
