//
//  RequestRetryViewModifier.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 03/05/2022.
//

import SwiftUI

struct RequestRetryViewModifier: ViewModifier {
    
    let isShown: Bool
    let retryBtnOnTap: (() -> Void)
    
    func body(content: Content) -> some View {
        ZStack {
            content.animation(.none, value: isShown)
            requestRetryView
        }
        .animation(.easeInOut(duration: 0.5), value: isShown)
    }
}

// MARK: components
extension RequestRetryViewModifier {
    @ViewBuilder
    private var requestRetryView: some View {
        if isShown {
            ZStack {
                Color(UIColor.systemBackground)
                
                VStack(spacing: 12.0) {
                    Spacer()
                    Spacer()
                    
                    Image(systemName: "wifi.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80.0, height: 80.0)
                        .foregroundColor(.gray)
                    
                    Text("You are currently offline. Please check your internet connection and retry later.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                    
                    Button {
                        retryBtnOnTap()
                    } label: {
                        Text("Retry")
                            .font(.headline)
                            .frame(width: 150.0, height: 40.0)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .strokeBorder(.blue)
                            )
                    }
                    .padding(.top, 6.0)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 12.0)
            }
            .edgesIgnoringSafeArea(.bottom)
            .zIndex(2.0)
        }
    }
}

extension View {
    func requestRetryView(isShown: Bool, retryBtnOnTap: @escaping () -> Void) -> some View {
        modifier(RequestRetryViewModifier(isShown: isShown, retryBtnOnTap: retryBtnOnTap))
    }
}
