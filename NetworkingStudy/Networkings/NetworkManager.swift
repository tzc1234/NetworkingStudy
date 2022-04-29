//
//  NetworkManager.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import Foundation
import Combine

enum NetworkMangerError: Error {
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

class NetworkManager {
    static func request<T: Codable>(endPoint: JSONPlaceholderEndPoint) -> AnyPublisher<T, NetworkMangerError> {
        guard let url = getComponents(endPoint: endPoint).url else {
            return Fail<T, NetworkMangerError>(error: .invalidUrl)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method
        
        let session = URLSession(configuration: .default)
        let publisher = session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode == 200 else {
                    throw NetworkMangerError.invalidServerResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { error -> Fail<T, NetworkMangerError> in
                let error = (error as? NetworkMangerError) ?? .unspecified(error)
                return Fail(error: error)
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    static func request<T: Codable>(endPoint: JSONPlaceholderEndPoint) async throws -> T {
        guard let url = getComponents(endPoint: endPoint).url else {
            throw NetworkMangerError.invalidUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method
        
        let session = URLSession(configuration: .default)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkMangerError.invalidServerResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    static func request<T: Codable>(endPoint: JSONPlaceholderEndPoint, completion: @escaping (Result<T, NetworkMangerError>) -> Void) {
        guard let url = getComponents(endPoint: endPoint).url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(.unspecified(error!)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidServerResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(responseObject))
                } catch {
                    completion(.failure(.dataDecodeFailure))
                }
            }
        }
        
        dataTask.resume()
    }
    
    static func getComponents(endPoint: JSONPlaceholderEndPoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.parameters
        return components
    }
}

