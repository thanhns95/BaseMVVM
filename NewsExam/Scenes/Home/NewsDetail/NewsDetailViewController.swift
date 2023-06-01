//
//  NewsDetailViewController.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import UIKit
import RxSwift

class NewsDetailViewController: UIViewController {
    var viewModel: NewsDetailViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.isScrollEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.silver
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium(size: 17)
        label.textColor = Colors.metallicSeaweed
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular(size: 14)
        label.textColor = Colors.black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let updatedDateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular(size: 12)
        label.textColor = Colors.silver
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
      override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewModel()
        initData()
    }
    
    private func setData(_ news: News) {
        imageView.kf.setImage(with: URL(string: news.urlToImage ?? ""), placeholder: nil, options: nil, completionHandler: nil)
        contentLabel.text = news.content
        titleLabel.text = news.title
        updatedDateLabel.text = news.publishedAt
    }
}

extension NewsDetailViewController: BaseViewController {
    typealias ViewModel = NewsDetailViewModel
    
    func setupViews() {
        title = "Detail"
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        [imageView, stackView].forEach({ scrollView.addSubview($0) })
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(9.0 / 16.0)
            make.width.equalTo(view.snp.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.equalTo(scrollView.snp.leadingMargin).offset(16)
            make.trailing.equalTo(scrollView.snp.trailingMargin).offset(-16)
            make.bottom.equalTo(scrollView.snp.bottomMargin)
        }
        
        [titleLabel, contentLabel, updatedDateLabel].forEach({ stackView.addArrangedSubview($0) })
    }
    
    func bindViewModel() {
        viewModel.output.newsData.subscribe(onNext: { [weak self] news in
            self?.setData(news)
        }).disposed(by: disposeBag)
    }
    
    func initData() {}
}

extension NewsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, offsetY / 2, 0)
            let scaleFactor = 1 - (offsetY / imageView.bounds.height)
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            imageView.layer.transform = transform
        } else {
            imageView.layer.transform = CATransform3DIdentity
        }
    }
}
