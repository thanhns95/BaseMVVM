//
//  NewsEmptyView.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import UIKit

class NewsEmptyView: UIView {
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No news found!"
        label.font = Fonts.medium(size: 20)
        label.textColor = Colors.silver
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
