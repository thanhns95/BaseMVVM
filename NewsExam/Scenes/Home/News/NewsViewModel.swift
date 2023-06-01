//
//  NewsViewModel.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import Foundation
import RxSwift
import Network
import Kingfisher

 class NewsViewModel: BaseViewModel {
    private let searchText = PublishSubject<String?>()
    private let page = BehaviorSubject<Int>(value: 1)
    private let loadmore = PublishSubject<Void>()
    private let refresh = PublishSubject<Void>()
    private let canLoadmore = BehaviorSubject<Bool>(value: true)
    private let isLoadmore = BehaviorSubject<Bool>(value: false)
    private let activityTracker = ActivityTracker<String>()
    private let errorTracker = ErrorTracker()
    private let news = PublishSubject<[News]>()
    private let onNextDetail = PublishSubject<News>()
    private let preloadImageUrl = PublishSubject<[URL]>()
    private let pageSize: Int = 20
    private let disposeBag = DisposeBag()
    
    struct Input {
        var searchText: AnyObserver<String?>
        var loadmore: AnyObserver<Void>
        var refresh: AnyObserver<Void>
        var onNextDetail: AnyObserver<News>
        var preloadImageUrl: AnyObserver<[URL]>
    }
    
    struct Output {
        var news: Observable<[News]>
        var onPage: Observable<Int>
        var showLoading: Observable<Bool>
        var onNextDetail: Observable<News>
        var onError: Observable<Error>
    }
    
    var input: Input
    var output: Output
    var network: Network
    
    init(network: Network) {
        input = Input(
            searchText: searchText.asObserver(),
            loadmore: loadmore.asObserver(),
            refresh: refresh.asObserver(),
            onNextDetail: onNextDetail.asObserver(),
            preloadImageUrl: preloadImageUrl.asObserver()
        )
        output = Output(
            news: news.asObservable(),
            onPage: page.asObservable(),
            showLoading: activityTracker.status(for: LOADING_KEY),
            onNextDetail: onNextDetail.asObservable(),
            onError: errorTracker.asObservsable()
        )
        self.network = network
        
        searchText
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.canLoadmore.onNext(true)
                self.isLoadmore.onNext(false)
                self.page.onNext(1)
            }).disposed(by: disposeBag)
        
        page
            .withLatestFrom(searchText) { ($0, $1) }
            .subscribe(onNext: { [weak self] (page, keyword) in
                guard let self = self else {
                    return
                }
                self.requestNews(keyword: keyword, page: page, pageSize: self.pageSize)
        }).disposed(by: disposeBag)
        
        loadmore
            .withLatestFrom(
                Observable.combineLatest(page, isLoadmore, canLoadmore)
            ) { ($0, $1.0, $1.1, $1.2) }
            .subscribe(onNext: { [weak self] (_, page, isLoadmore, canLoadmore) in
                guard let self = self, canLoadmore, !isLoadmore else {
                    return
                }
                self.page.onNext(page + 1)
        }).disposed(by: disposeBag)
        
        refresh.subscribe(onNext: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.canLoadmore.onNext(true)
            self.isLoadmore.onNext(false)
            self.page.onNext(1)
        }).disposed(by: disposeBag)
        
        preloadImageUrl.subscribe(onNext: { urls in
            ImagePrefetcher(resources: urls).start()
        }).disposed(by: disposeBag)
    }
    
    private func requestNews(keyword: String?, page: Int, pageSize: Int) {
        isLoadmore.onNext(true)
        let fetchNews: Single<NewsResponse>
        if page == 1 {
            fetchNews = NewsService(network: network)
                .fetchNews(keyword: keyword, page: page, pageSize: pageSize)
                .trackActivity(LOADING_KEY, with: activityTracker)
        } else {
            fetchNews = NewsService(network: network)
                .fetchNews(keyword: keyword, page: page, pageSize: pageSize)
        }
            
        fetchNews
            .trackError(errorTracker)
            .subscribe(onSuccess: { [weak self] response in
                self?.canLoadmore.onNext(response.totalResults >= page * pageSize)
                self?.news.onNext(response.articles)
            }, onFailure: { [weak self] error in
                self?.canLoadmore.onNext(false)
            }, onDisposed: { [weak self] in
                self?.isLoadmore.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}
