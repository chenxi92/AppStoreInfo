//
//  CachedAsyncImage.swift
//  AppStoreInfo
//
//  Created by peak on 2021/12/22.
//

import SwiftUI

extension URLCache {
    public static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

public struct CachedAsyncImage<Content>: View where Content: View {
    @State private var phase: AsyncImagePhase = .empty
    
    private let url: URL?
    private let urlSession: URLSession
    private let content: (AsyncImagePhase) -> Content
    
    public var body: some View {
        content(phase)
            .task(id: url) {
                await load(url: url)
            }
    }
    
    public init(url: URL?, urlCache: URLCache = .imageCache) where Content == Image {
        self.init(url: url, urlCache: urlCache) { phase in
#if os(macOS)
            phase.image ?? Image(nsImage: .init())
#else
            phase.image ?? Image(uiImage: .init())
#endif
        }
    }
    
    public init(
        url: URL?,
        urlCache: URLCache = .imageCache,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content)
    {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.url = url
        self.urlSession =  URLSession(configuration: configuration)
        self.content = content
    }
    
    
    public init<I, P>(
        url: URL?,
        urlCache: URLCache = .imageCache,
        @ViewBuilder content: @escaping(Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View
    {
        self.init(url: url, urlCache: urlCache) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
    
    private func load(url: URL?) async {
        do {
            guard let url = url else { return }
            let request = URLRequest(url: url)
            let (data, _) = try await urlSession.data(for: request)
#if os(macOS)
            if let nsImage = NSImage(data: data) {
                let image = Image(nsImage: nsImage)
                phase = .success(image)
            } else {
                throw AsyncImage<Content>.LoadingError()
            }
#else
            if let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                phase = .success(image)
            } else {
                throw AsyncImage<Content>.LoadingError()
            }
#endif
        } catch {
            phase = .failure(error)
        }
    }
}

private extension AsyncImage {
    struct LoadingError: Error {
    }
}


