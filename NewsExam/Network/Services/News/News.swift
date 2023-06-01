//
//  NewsModel.swift
//  Home
//
//  Created by it on 28/10/2022.
//

import Foundation

class NewsResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [News]
}

class News: Decodable {
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}
