//
//  ImageFetchNetworkService.swift
//  Music Player
//
//  Created by Даниил on 21.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import AlamofireImage

protocol ImageFetchNetworkServiceDelegate: FetchingErrorHandler {

    func imageFetchNetworkSeriviceDidGet(_ images: [String : Image], with modelType: ModelType)
    
    func imageFetchNetworkSeriviceDidGet(_ nestedImages: [[String:Image]])
}

protocol ImageFetchNetworkService {
    
    var imageFetcherDelegate: ImageFetchNetworkServiceDelegate? { get set }
    
    func fetchImages(from urls: [String], for modelType: ModelType)
    
    func fetchNestedImages(from nestedUrls: [[String]])
}
