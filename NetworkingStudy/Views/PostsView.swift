//
//  PostsView.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import SwiftUI
import Combine

struct PostsView: View {
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var isLoading = false
    @State private var posts: [Post] = []
    
//    let userId: Int
    
    var body: some View {
        LoadingView(isLoading: isLoading) {
            List {
                ForEach(posts) { post in
                    VStack(spacing: 6.0) {
                        Text(post.title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("UserId: \(post.userId)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(post.body)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle("Posts")
        }
        .onAppear {
            isLoading = true
            NetworkManager.getPostsByFirstUser()
//            NetworkManager.getPostsByErrorUser()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.errorMsg)
                    }
                } receiveValue: { posts in
                    self.posts = posts
                }
                .store(in: &subscriptions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
