//
//  NewsService.swift
//  NewsExam
//
//  Created by it on 30/05/2023.
//

import RxSwift

protocol NewsServiceType {
    func fetchNews(keyword: String?, page: Int, pageSize: Int) -> Single<NewsResponse>
}

class NewsService {
    
      let network: Network
    
      init(network: Network) {
        self.network = network
    }
    
}

extension NewsService: NewsServiceType {
      func fetchNews(keyword: String?, page: Int, pageSize: Int) -> Single<NewsResponse> {
        return network.rx.request(NewsEndpoint.news(keyword: keyword, page: page, pageSize: pageSize))
            .validate()
            .responseDecodable(of: NewsResponse.self)
    }
}
