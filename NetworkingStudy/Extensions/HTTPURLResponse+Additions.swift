//
//  HTTPURLResponse+Additions.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 06/05/2022.
//

import Foundation

extension HTTPURLResponse {
    var isSuccess: Bool {
        200..<300 ~= statusCode
    }
}
