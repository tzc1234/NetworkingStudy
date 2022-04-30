//
//  NetworkManagerError.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import Foundation

enum NetworkManagerError: Error {
    case invalidUrl
    case unspecified(Error)
    case noUsers
    case unexpected
    case noData
    case dataDecodeFailure
    case invalidServerResponse
    
    var errorMsg: String {
        switch self {
        case .invalidUrl:
            return "Invalid Url."
        case .unspecified(let error):
            return error.localizedDescription
        case .noUsers:
            return "No Users."
        case .unexpected:
            return "Unexpected Error Occured."
        case .noData:
            return "No data received."
        case .dataDecodeFailure:
            return "Cannot decode data."
        case .invalidServerResponse:
            return "Invalid Server Response."
        }
    }
}
