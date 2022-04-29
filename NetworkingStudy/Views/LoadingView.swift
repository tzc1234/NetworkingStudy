//
//  LoadingView.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
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

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
