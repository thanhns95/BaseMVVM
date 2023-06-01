//
//  NewsViewController.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import UIKit
import SnapKit
import RxSwift
import SkeletonView

class NewsViewController: UIViewController {
     var viewModel: NewsViewModel!
    
    private let disposeBag = DisposeBag()
    private var newsArray: [News] = [] {
        didSet {
            
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isSkeletonable = true
        tableView.prefetchDataSource = self
        return tableView
    }()
    
    private let searchView = UIView()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.font = Fonts.medium(size: 13)
        searchBar.searchTextField.textColor = Colors.black
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewModel()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(notification:)),
                                               name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(notification:)),
                                               name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func refreshData() {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.refreshControl.endRefreshing()
        }, completion: nil)
        viewModel.input.refresh.onNext(())
    }
}

extension NewsViewController: BaseViewController {
     typealias ViewModel = NewsViewModel
    
     func bindViewModel() {
         let output = viewModel.output
         output
            .news
            .withLatestFrom(output.onPage) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] (newsArray, page) in
                    guard let self = self else {
                        return
                    }
                    if page == 1 {
                        self.newsArray = newsArray
                        self.tableView.reloadData()
                    } else {
                        let oldCount = self.newsArray.count
                        self.newsArray.append(contentsOf: newsArray)
                        self.tableView.insertRows(at: (oldCount..<self.newsArray.count).map({ IndexPath(row: $0, section: 0) }), with: .none)
                    }
                    if self.newsArray.isEmpty {
                        self.tableView.backgroundView = NewsEmptyView()
                    } else {
                        self.tableView.backgroundView = nil
                    }
                }
            ).disposed(by: disposeBag)
        
         output
            .showLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] isShow in
                    if isShow {
                        self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                        self?.tableView.showAnimatedGradientSkeleton()
                    } else {
                        self?.tableView.hideSkeleton()
                    }
                }
            ).disposed(by: disposeBag)
         
         output
             .onError
             .subscribe(onNext: { [weak self] error in
                 self?.showAlert(message: error.localizedDescription)
             })
             .disposed(by: disposeBag)
    }
    
     func setupViews() {
        title = "News"
        
        view.backgroundColor = .white
        [searchView, tableView].forEach {
            view.addSubview($0)
        }
        
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsTableViewCell")
        tableView.refreshControl = refreshControl
        tableView.estimatedRowHeight = 316
        
        searchView.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.leading.equalTo(8)
            make.trailing.bottom.equalTo(-8)
            make.height.equalTo(40)
        }
    }
    
     func initData() {
        viewModel.input.searchText.onNext(nil)
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.snp.updateConstraints { make in
                make.bottom.equalTo(-keyboardSize.size.height)
            }
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
            }
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardHide(notification: NSNotification) {
        tableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension NewsViewController: SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.setData(newsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "NewsTableViewCell"
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.input.onNextDetail.onNext(newsArray[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // if only half of screen height until bottom => loadmore
        if scrollView.contentOffset.y + (scrollView.bounds.height * 3 / 2) > scrollView.contentSize.height {
            viewModel.input.loadmore.onNext(())
        }
    }
}

extension NewsViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.input.searchText.onNext(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        viewModel.input.searchText.onNext(nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap({ URL(string: newsArray[safe: $0.row]?.urlToImage ?? "") })
        viewModel.input.preloadImageUrl.onNext(urls)
    }
}
