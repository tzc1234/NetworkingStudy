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
    
    static func getUsers() -> AnyPublisher<[User], NetworkManagerError> {
        return request(endPoint: .getUsers, type: [User].self)
    }
    
    static func getErrUsers() -> AnyPublisher<[User], NetworkManagerError> {
        print("getErrUsers called.")
        return Fail<[User], NetworkManagerError>(error: .invalidUrl).eraseToAnyPublisher()
    }
    
    static func getZeroUser() -> AnyPublisher<[User], NetworkManagerError> {
        Just<[User]>([]).setFailureType(to: NetworkManagerError.self).eraseToAnyPublisher()
    }
    
    static func getPostsByErrorUser() -> AnyPublisher<[Post], NetworkManagerError> {
        let publisher =
        getZeroUser()
            .print()
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
    
    // Once the error from getErrUsers occurred, retry getErrUsers more 3 time with delay 3s each.
    static func delayAndRetryErrUsers() -> AnyPublisher<[User], NetworkManagerError> {
        let publisher = getErrUsers()
            .catch { error -> AnyPublisher<[User], NetworkManagerError> in
                return getErrUsers()
                    .print()
                    .delay(for: .seconds(3.0), scheduler: DispatchQueue.global())
                    .retry(3)
                    .eraseToAnyPublisher()
            }
        return publisher.eraseToAnyPublisher()
    }
    
    // Can each retry with different delay in secounds?
    // Can this not be achieved by recursion?
    static func delayAndRetryErrUsers(inSeconds delaySeconds: Double, retryTimes: Int, retryCount: Int = 0) -> AnyPublisher<[User], NetworkManagerError> {
        print("delay in seconds: \(delaySeconds), retry times: \(retryTimes), retry count: \(retryCount)")
        guard retryTimes > 0 else { return getErrUsers() }
        
        // The 3rd retry, switch to success case.
        if retryCount == 3 {
            return getUsers()
        }
        
        return getErrUsers()
            .delay(for: .seconds(delaySeconds), scheduler: DispatchQueue.global())
            .catch { error -> AnyPublisher<[User], NetworkManagerError> in
                return delayAndRetryErrUsers(inSeconds: delaySeconds + 1, retryTimes: retryTimes - 1, retryCount: retryCount + 1)
            }
            .print()
            .eraseToAnyPublisher()
    }
}
