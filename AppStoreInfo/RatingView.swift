//
//  RatingView.swift
//  AppStoreInfo
//
//  Created by peak on 2021/12/22.
//

import SwiftUI

struct RatingView: View {
    let maxRating: Int
    var rating: Double
    
    init(_ rating: Double, maxRating: Int = 5) {
        self.rating = rating
        self.maxRating = maxRating
    }

    var body: some View {
        HStack {
            ForEach(0..<Int(rating), id: \.self) { idx in
                fullStar
            }

            if (rating != floor(rating)) {
                halfStar
            }

            ForEach(0..<Int(Double(maxRating) - rating), id: \.self) { idx in
                emptyStar
            }
        }
    }

    private var fullStar: some View {
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
    }

    private var halfStar: some View {
        Image(systemName: "star.leadinghalf.fill")
            .foregroundColor(.yellow)
    }

    private var emptyStar: some View {
        Image(systemName: "star")
    }
}


struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(3.5)
    }
}
