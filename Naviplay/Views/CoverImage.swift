//
//  CoverImage.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import SwiftUI

struct CoverImage: View {
    let coverImageURL: URL?
    let size: CGSize

    var body: some View {
        if let coverImageURL {
            AsyncImage(url: coverImageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                case .failure:
                    Color.gray
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Color.gray
        }
    }
}

struct CoverImage_Previews: PreviewProvider {
    static var previews: some View {
        CoverImage(
            coverImageURL: AppState.mock.coverImageURL(song: .mock),
            size: .init(width: 100, height: 100)
        )
    }
}
