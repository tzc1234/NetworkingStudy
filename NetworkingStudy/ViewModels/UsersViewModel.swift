//
//  UsersViewModel.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 03/05/2022.
//

import Foundation
import Combine
import SwiftUI

final class UsersViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var subscriptions = Set<AnyCancellable>()
    
    @Published private(set) var isShownRetryView = false
    private var lastRequest: NetworkManager.Requests?
}

// MARK: functions
extension UsersViewModel {
    func getUsers(withLoading: Bool = true) {
        isLoading = withLoading
        
        NetworkManager.shared.getUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self?.isLoading = false
                }
                
                switch completion {
                case .finished:
                    self?.isShownRetryView = false
                case .failure(let error):
                    switch error {
                    case .networkUnavailable:
                        self?.lastRequest = .getUsers
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.isShownRetryView = true
                        }
                    default:
                        print("ERROR: \(error.errorMsg)")
                    }
                }
            } receiveValue: { [weak self] (users: [User]) in
                self?.users = users
            }
            .store(in: &subscriptions)
    }
    
    func retryLastRequest() {
        guard let lastRequest = lastRequest else { return }
        self.lastRequest = nil
        
        switch lastRequest {
        case .getUsers:
            getUsers()
        default:
            break
        }
    }
}
