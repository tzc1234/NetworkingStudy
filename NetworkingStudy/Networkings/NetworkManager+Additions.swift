//
//  NetworkManager+Addtitions.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 30/04/2022.
//

import Foundation
import Combine

extension NetworkManager {
    static func getPostsByFirstUser() -> AnyPublisher<[Post], NetworkManagerError> {
        let publisher = request(endPoint: .getUsers, type: [User].self)
            .flatMap { users -> AnyPublisher<[Post], NetworkManagerError> in
                guard let firstUserId = users.first?.id else {
                    return Fail<[Post], NetworkManagerError>(error: .noUsers)
                        .eraseToAnyPublisher()
                }
                print("*** firstUserId: \(firstUserId) ***")
                return request(endPoint: .getPosts(userId: firstUserId), type: [Post].self)
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    static func getErrUsers() -> AnyPublisher<[User], NetworkManagerError> {
        Fail<[User], NetworkManagerError>(error: .invalidUrl).eraseToAnyPublisher()
    }
    
    static func getZeroUser() -> AnyPublisher<[User], NetworkManagerError> {
        Just<[User]>([]).setFailureType(to: NetworkManagerError.self).eraseToAnyPublisher()
    }
    
    static func getPostsByErrorUser() -> AnyPublisher<[Post], NetworkManagerError> {
        let publisher =
//        getErrUsers()
        getZeroUser()
            .flatMap { users -> AnyPublisher<[Post], NetworkManagerError> in
                guard let firstUserId = users.first?.id else {
                    return Fail<[Post], NetworkManagerError>(error: .noUsers)
                        .eraseToAnyPublisher()
                }
                print("*** firstUserId: \(firstUserId) ***")
                return request(endPoint: .getPosts(userId: firstUserId), type: [Post].self)
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    
}
