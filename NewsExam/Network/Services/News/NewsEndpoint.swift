//
//  NewsEndpoint.swift
//  Home
//

import Foundation
import Alamofire

enum NewsEndpoint: EndPointConvertible {
    case news(keyword: String?, page: Int, pageSize: Int)

    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "v2/everything"
    }
    
    var encoder: HTTPEncoder {
        switch self {
        case let .news(keyword, page, pageSize):
            var parameters: [String : Any] = ["apiKey": "e46c1268e5da41398785dd7fd0259168",
                                              "page": page,
                                              "pageSize": pageSize]
            if let keyword = keyword, !keyword.isEmpty {
                parameters["q"] = keyword
            } else {
                parameters["q"] = "q"
            }
            return .urlEncoder(parameters: parameters)
        }
    }
}
