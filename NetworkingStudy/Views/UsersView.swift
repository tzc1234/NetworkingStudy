//
//  UsersView.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import SwiftUI
import Combine

struct UsersView: View {
    
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ZStack {
                List(users) { user in
//                    NavigationLink {
//                        PostsView()
//                    } label: {
//
//                    }
                    VStack(spacing: 6.0) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(user.username)
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(user.email)
                            .font(.body)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .listStyle(.grouped)
                .navigationTitle("Users")
                
                if isLoading {
                    LoadingView()
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            isLoading = true
//            let pub: AnyPublisher<[User], NetworkManagerError> = NetworkManager.request(endPoint: .getUsers)
//            let pub: AnyPublisher<[User], NetworkManagerError> = NetworkManager.requestForFuture(endPoint: .getUsers)
//            let pub: AnyPublisher<[User], NetworkManagerError> = NetworkManager.asyncRequestForFuture(endPoint: .getUsers)
//            pub
//                .receive(on: DispatchQueue.main)
//                .sink { completion in
//                    isLoading = false
//                    switch completion {
//                    case .finished:
//                        break
//                    case .failure(let error):
//                        print(error.errorMsg)
//                    }
//                } receiveValue: { (users: [User]) in
//                    self.users = users
//                }
//                .store(in: &subscriptions)

            NetworkManager.delayAndRetryErrUsers(inSeconds: 3, retryTimes: 10)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("ERROR: \(error.errorMsg)")
                    }
                } receiveValue: { (users: [User]) in
                    self.users = users
                }
                .store(in: &subscriptions)
        }
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
