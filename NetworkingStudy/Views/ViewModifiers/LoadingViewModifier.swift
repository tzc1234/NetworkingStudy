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
            content.animation(.none, value: isLoading)
            loadingLayer
        }
        .animation(.easeInOut(duration: 0.6), value: isLoading)
    }
}

// MARK: functions
extension LoadingViewModifier {
    @ViewBuilder
    private var loadingLayer: some View {
        if isLoading {
            ZStack {
                Color.clear
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(2.0)
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.black)
                            .frame(width: 90.0, height: 90.0)
                    )
            }
            .ignoresSafeArea()
            .zIndex(3.0)
        }
    }
}

extension View {
    func loadingView(isLoading: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
