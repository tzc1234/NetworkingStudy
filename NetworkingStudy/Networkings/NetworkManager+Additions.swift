//
//  NetworkManager+Addtitions.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 30/04/2022.
//

import Foundation
import Combine

extension NetworkManager {
    enum Requests {
        case getPostsByFirstUser
        case getUsers
        case delayAndRetryErrUsers(delaySeconds: Double, retryTimes: Int, retryCount: Int)
    }
    
    func getPostsByFirstUser() -> AnyPublisher<[Post], NetworkManagerError> {
        let publisher = Self.request(endPoint: .getUsers, type: [User].self)
            .flatMap { users -> AnyPublisher<[Post], NetworkManagerError> in
                guard let firstUserId = users.first?.id else {
                    return Fail<[Post], NetworkManagerError>(error: .noUsers)
                        .eraseToAnyPublisher()
                }
                print("*** firstUserId: \(firstUserId) ***")
                return Self.request(endPoint: .getPosts(userId: firstUserId), type: [Post].self)
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    func getUsers() -> AnyPublisher<[User], NetworkManagerError> {
        return Self.request(endPoint: .getUsers, type: [User].self)
    }
    
    func getErrUsers() -> AnyPublisher<[User], NetworkManagerError> {
        print("getErrUsers called.")
        return Fail<[User], NetworkManagerError>(error: .invalidUrl).eraseToAnyPublisher()
    }
    
    func getZeroUser() -> AnyPublisher<[User], NetworkManagerError> {
        Just<[User]>([]).setFailureType(to: NetworkManagerError.self).eraseToAnyPublisher()
    }
    
    func getPostsByErrorUser() -> AnyPublisher<[Post], NetworkManagerError> {
        let publisher =
        getErrUsers()
            .print()
            .flatMap { users -> AnyPublisher<[Post], NetworkManagerError> in
                guard let firstUserId = users.first?.id else {
                    return Fail<[Post], NetworkManagerError>(error: .noUsers)
                        .eraseToAnyPublisher()
                }
                print("*** firstUserId: \(firstUserId) ***")
                return Self.request(endPoint: .getPosts(userId: firstUserId), type: [Post].self)
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    // Once the error from getErrUsers occurred, retry getErrUsers more 3 time with delay 3s each.
    func delayAndRetryErrUsers() -> AnyPublisher<[User], NetworkManagerError> {
        let errUsersPublisher = getErrUsers()
        let publisher = getErrUsers()
            .catch { error -> AnyPublisher<[User], NetworkManagerError> in
                return errUsersPublisher
                    .print()
                    .delay(for: .seconds(3.0), scheduler: DispatchQueue.global())
                    .retry(3)
                    .eraseToAnyPublisher()
            }
        return publisher.eraseToAnyPublisher()
    }
    
    // Can each retry with different delay in secounds?
    // Can this not be achieved by recursion?
    func delayAndRetryErrUsers(inSeconds delaySeconds: Double, retryTimes: Int, retryCount: Int = 0) -> AnyPublisher<[User], NetworkManagerError> {
        print("delay in seconds: \(delaySeconds), retry times: \(retryTimes), retry count: \(retryCount)")
        guard retryTimes > 0 else { return getErrUsers() }
        
        // The 3rd retry, switch to success case.
        if retryCount == 3 {
            return getUsers()
        }
        
        return getErrUsers()
            .delay(for: .seconds(delaySeconds), scheduler: DispatchQueue.global())
            .catch { [weak self] error -> AnyPublisher<[User], NetworkManagerError> in
                guard let self = self else {
                    return Fail<[User], NetworkManagerError>(error: .unspecified(error))
                        .eraseToAnyPublisher()
                }
                return self.delayAndRetryErrUsers(inSeconds: delaySeconds + 1, retryTimes: retryTimes - 1, retryCount: retryCount + 1)
            }
            .print()
            .eraseToAnyPublisher()
    }
}
