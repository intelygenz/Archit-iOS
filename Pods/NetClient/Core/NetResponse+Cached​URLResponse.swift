//
//  NetResponse+CachedURLResponse.swift
//  Net
//
//  Created by Alex Rupérez on 22/3/17.
//
//

import Foundation

extension NetResponse {

    public init(_ cachedResponse: CachedURLResponse, _ netTask: NetTask? = nil) {
        self.init(cachedResponse.response.url, mimeType: cachedResponse.response.mimeType, contentLength: cachedResponse.response.expectedContentLength, textEncoding: cachedResponse.response.textEncodingName, filename: cachedResponse.response.suggestedFilename, userInfo: cachedResponse.userInfo, netTask: netTask, responseObject: cachedResponse.data)
    }
    
}
