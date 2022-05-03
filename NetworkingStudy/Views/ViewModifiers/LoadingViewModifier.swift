//
//  LoadingViewModifier.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 03/05/2022.
//

import SwiftUI

struct LoadingViewModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            loadingLayer
        }
    }
    
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

extension View {
    func loadingView(isLoading: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
