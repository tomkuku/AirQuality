//
//  InMemoryDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/06/2024.
//

import Foundation

protocol HasCacheDataSource {
    var cacheDataSource: CacheDataSourceProtocol { get }
}

protocol CacheDataSourceProtocol: Sendable {
    func set<T>(url: URL?, value: T) async where T: Sendable
    func get<T>(url: URL?) async -> T? where T: Sendable
}

actor CacheDataSource: CacheDataSourceProtocol {
    private var dictionary: [String: Any] = [:]
    
    func set<T>(url: URL?, value: T) async where T: Sendable {
        guard let urlString = url?.absoluteString else {
            Logger.error("Url is nil!")
            return
        }
        
        dictionary[urlString] = value
    }
    
    func get<T>(url: URL?) async -> T? where T: Sendable {
        guard let urlString = url?.absoluteString else {
            Logger.error("Url is nil!")
            return nil
        }
        
        return dictionary[urlString] as? T
    }
}
