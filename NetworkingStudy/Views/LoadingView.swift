//
//  LoadingView.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import SwiftUI

struct LoadingView<Content: View>: View {
    
    let isLoading: Bool
    let content: Content
    
    init(isLoading: Bool, @ViewBuilder content: () -> Content) {
        self.isLoading = isLoading
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            loadingLayer
        }
    }
}

// MARK: components
extension LoadingView {
    @ViewBuilder
    private var loadingLayer: some View {
        if isLoading {
            ZStack {
                Color.clear
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(2)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                            .frame(width: 90, height: 90)
                    )
            }
            .ignoresSafeArea()
        }
    }
}
