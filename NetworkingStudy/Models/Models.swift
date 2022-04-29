//
//  Models.swift
//  NetworkingStudy
//
//  Created by Tsz-Lung on 29/04/2022.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name, username, email: String
}

struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title, body: String
}

struct Comment: Codable, Identifiable {
    let postId, id: Int
    let name, email, body: String
}
