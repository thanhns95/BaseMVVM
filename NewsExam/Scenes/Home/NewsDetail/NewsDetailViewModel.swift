//
//  DetailViewModel.swift
//  Home
//
//  Created by it on 16/08/2022.
//

import Foundation
import RxSwift

class NewsDetailViewModel: BaseViewModel {
     struct Input {}
    
     struct Output {
        var newsData: Observable<News>
    }
    
     var input: Input
     var output: Output
    
    private let newsData: BehaviorSubject<News>
    
    init(news: News) {
        newsData = BehaviorSubject(value: news)
        
        input = Input()
        output = Output(newsData: newsData.asObservable())
    }
}
