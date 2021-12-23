//
//  ViewModel.swift
//  AppStoreInfo
//
//  Created by peak on 2021/12/22.
//

import Foundation
import Combine
import SwiftUI

enum FetchStatus {
    case idle
    case loading
    case success
    case fail(Error)
}

class ViewModel: ObservableObject {
    private let baseURLString = "https://itunes.apple.com/br/lookup?bundleId="
    private var cancellable: AnyCancellable?
    
    @Published private(set)var results: AppMetadataResults = AppMetadataResults(results: [])
    @Published private(set)var status: FetchStatus = .idle
        
    init() {
    }
    
    enum FetchError: Error {
        case emptyData
    }
    
    func fetch(bundleId: String) {
        status = .loading
        
        let urlString = baseURLString + bundleId
        let url = URL(string: urlString)!
        print("request url: \(url)")
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(
                type: AppMetadataResults.self,
                decoder: JSONDecoder()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completeStatus in
                switch completeStatus {
                case .failure(let error):
                    self?.status = .fail(error)
                default:
                    break
                }
            } receiveValue: { result in
                self.results = result
                print(String(describing: self.results))
                if self.results.results.isEmpty {
                    self.status = .fail(FetchError.emptyData)
                } else {
                    self.status = .success
                }
            }
    }
}
