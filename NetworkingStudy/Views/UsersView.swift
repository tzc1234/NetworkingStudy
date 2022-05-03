//
//  UsersView.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import SwiftUI
import Combine

struct UsersView: View {
    
    @StateObject private var vm = UsersViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.users) { user in
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
            }
            .requestRetryView(isShown: vm.isShownRetryView, retryBtnOnTap: vm.retryLastRequest)
            .loadingView(isLoading: vm.isLoading)
            .listStyle(.grouped)
            .navigationTitle("Users")
            .refreshable {
                vm.getUsers(withLoading: false)
            }
            
        }
        .navigationViewStyle(.stack)
        .onAppear {
            vm.getUsers()
        }
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
