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
    
    let userId: Int
    
    var body: some View {
        ZStack {
            List {
                ForEach(posts) { post in
                    VStack(spacing: 6.0) {
                        Text(post.title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(post.body)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle("Posts")
            
            if isLoading {
                LoadingView()
            }
        }
        .onAppear {
            isLoading = true
            NetworkManager.request(endPoint: .getPosts(userId: userId)) { (result: Result<[Post], NetworkMangerError>) in
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let failure):
                    print(failure.errorMsg)
                }
                isLoading = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView(userId: 1)
    }
}
