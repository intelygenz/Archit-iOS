//
//  NetResponse+URLResponse.swift
//  Net
//
//  Created by Alex Rupérez on 22/3/17.
//
//

import Foundation

extension NetResponse {

    public init(_ response: URLResponse, _ netTask: NetTask? = nil, _ responseObject: Any? = nil) {
        self.init(response.url, mimeType: response.mimeType, contentLength: response.expectedContentLength, textEncoding: response.textEncodingName, filename: response.suggestedFilename, netTask: netTask, responseObject: responseObject)
    }
    
}
