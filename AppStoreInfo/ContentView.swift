//
//  ContentView.swift
//  AppStoreInfo
//
//  Created by peak on 2021/12/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    @AppStorage("selected.bundle.id")
    private var bundleId = ""
    
    @ObservedObject var vm = ViewModel()
    
    private enum ScreenTab {
        case iPhone
        case iPad
    }
    
    @State private var selectedTab:ScreenTab  = .iPhone
    
    private var appMetadata: AppMetadata {
        return self.vm.results.results.first!
    }
    
    var urls: [URL] {
        if selectedTab == .iPhone {
            return appMetadata.screenshotUrls
        }
        return appMetadata.ipadScreenshotUrls
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            switch vm.status {
            case .idle, .loading:
                ProgressView()
            case .fail(let error):
                VStack(alignment: .leading) {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Please try again!")
                }
            case .success:
                successContent
            }
        }
        .frame(minWidth: 700, minHeight: 560)
        .padding()
        .task {
            if !bundleId.isEmpty && bundleId.contains(".") {
                vm.fetch(bundleId: bundleId)
            }
        }
        .searchable(text: $bundleId)
        .onSubmit(of: .search) {
            if !bundleId.isEmpty && bundleId.contains(".") {
                vm.fetch(bundleId: bundleId)
            }
        }
    }
    
    var successContent: some View {
        VStack {
            titleInfo
            
            Divider()
            
            screenShot
            
            Divider()
            
            description
            
            Divider()
        }
    }
    
    var titleInfo: some View {
        HStack {
            AsyncImage(url: appMetadata.artworkUrl100) { image in
                image
                    .resizable()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            .padding(.vertical)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(appMetadata.trackName)
                        .font(.title.bold())
                    
                    Text(appMetadata.contentAdvisoryRating)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1)
                        )
                }
                
                Text(appMetadata.sellerName)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        openURL(appMetadata.trackViewUrl)
                    }
                
                if appMetadata.averageUserRating > 0 {
                    RatingView(appMetadata.averageUserRating)
                        .padding(.vertical, 2)
                }
                
                Text("Size: **\(appMetadata.size)MB**")
                    .padding(.vertical, 2)
                
                Text("Version: **\(appMetadata.version)**")
                    
            }
            .padding(.vertical)
        
            Spacer()
        }
    }
    
    var screenShot: some View {
        VStack(alignment: .leading, spacing: 0) {
            Picker("ScreenShot:", selection: $selectedTab) {
                Text("iPhone")
                    .tag(ScreenTab.iPhone)
                Text("iPad")
                    .tag(ScreenTab.iPad)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            

            ScrollView(.horizontal) {
                HStack {
                    ForEach(urls, id: \.self) { url in
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                        .frame(maxHeight: selectedTab == .iPhone ? 450 : 500)
                    }
                }
            }
                
        }
    }
    
    var description: some View {
        VStack(alignment: .leading) {

            Text(appMetadata.description)
            
            Divider()
            
            Text("News").font(.title.bold())
            
            Text(appMetadata.releaseNotes)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
