//
//  NetworkManager.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import Foundation
import Combine

class NetworkManager {
    /// URLSession dataTaskPublisher api call.
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
    
    /// async/await api call.
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
    
    /// wrap async/await api call to return a Result Publisher.
    static func asyncRequestToResultPublisher<T: Codable>(endPoint: JSONPlaceholderEndPoint) async -> AnyPublisher<T, NetworkMangerError> {
        print("asyncRequestToResultPublisher called.")
        do {
            let t: T = try await request(endPoint: endPoint)
            return Result<T, NetworkMangerError>.success(t).publisher.eraseToAnyPublisher()
        } catch {
            let networkMangerError = (error as? NetworkMangerError) ?? .unspecified(error)
            return Result<T, NetworkMangerError>.failure(networkMangerError).publisher.eraseToAnyPublisher()
        }
    }
    
    /// Traditional closure api call.
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
    
    /// Wrap traditional closure api call with Future Publisher.
    static func requestForFuture<T: Codable>(endPoint: JSONPlaceholderEndPoint) -> AnyPublisher<T, NetworkMangerError> {
        print("requestForFuture called.")
        return Future<T, NetworkMangerError> { promise in
            request(endPoint: endPoint) { (result: Result<T, NetworkMangerError>) in
                switch result {
                case .success(let success):
                    promise(.success(success))
                case .failure(let failure):
                    promise(.failure(failure))
                }
            }
        }
        .eraseToAnyPublisher()
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

