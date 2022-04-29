//
//  EndPoint.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import Foundation

protocol EndPoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem] { get }
    var method: String { get }
}

enum JSONPlaceholderEndPoint: EndPoint {
    case getPosts(userId: Int)
    case getUsers
    case getComments
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "jsonplaceholder.typicode.com"
        }
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        case .getUsers:
            return "/users"
        case .getComments:
            return "/comments"
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .getPosts(userId: let userId):
            return [URLQueryItem(name: "userId", value: "\(userId)")]
        default:
            return []
        }
    }
    
    var method: String {
        switch self {
        default:
            return "GET"
        }
    }
}
