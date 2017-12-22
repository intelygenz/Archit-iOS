//
//  NetResponse+Build.swift
//  Net
//
//  Created by Alex Rupérez on 28/3/17.
//
//

import Foundation

extension NetResponse {

    public class Builder {

        public private(set) var url: URL?

        public private(set) var mimeType: String?

        public private(set) var contentLength: Int64

        public private(set) var textEncoding: String?

        public private(set) var filename: String?

        public private(set) var statusCode: Int?

        public private(set) var headers: [AnyHashable : Any]?

        public private(set) var localizedDescription: String?

        public private(set) var userInfo: [AnyHashable : Any]?

        public private(set) weak var netTask: NetTask?
        
        public private(set) var responseObject: Any?

        public init(_ netResponse: NetResponse? = nil) {
            url = netResponse?.url
            mimeType = netResponse?.mimeType
            contentLength = netResponse?.contentLength ?? -1
            textEncoding = netResponse?.textEncoding
            filename = netResponse?.filename
            statusCode = netResponse?.statusCode
            headers = netResponse?.headers
            localizedDescription = netResponse?.localizedDescription
            userInfo = netResponse?.userInfo
            netTask = netResponse?.netTask
            responseObject = netResponse?.responseObject
        }

        @discardableResult open func setURL(_ url: URL?) -> Self {
            self.url = url
            return self
        }

        @discardableResult open func setMimeType(_ mimeType: String?) -> Self {
            self.mimeType = mimeType
            return self
        }

        @discardableResult open func setContentLength(_ contentLength: Int64) -> Self {
            self.contentLength = contentLength
            return self
        }

        @discardableResult open func setTextEncoding(_ textEncoding: String?) -> Self {
            self.textEncoding = textEncoding
            return self
        }

        @discardableResult open func setFilename(_ filename: String?) -> Self {
            self.filename = filename
            return self
        }

        @discardableResult open func setStatusCode(_ statusCode: Int?) -> Self {
            self.statusCode = statusCode
            return self
        }

        @discardableResult open func setHeaders(_ headers: [AnyHashable : Any]?) -> Self {
            self.headers = headers
            return self
        }

        @discardableResult open func setDescription(_ localizedDescription: String?) -> Self {
            self.localizedDescription = localizedDescription
            return self
        }

        @discardableResult open func setUserInfo(_ userInfo: [AnyHashable : Any]?) -> Self {
            self.userInfo = userInfo
            return self
        }

        @discardableResult open func setNetTask(_ netTask: NetTask?) -> Self {
            self.netTask = netTask
            return self
        }

        @discardableResult open func setObject(_ responseObject: Any?) -> Self {
            self.responseObject = responseObject
            return self
        }

        public func build() -> NetResponse {
            return NetResponse(self)
        }

    }

    public func builder() -> Builder {
        return NetResponse.builder(self)
    }

    public static func builder(_ netResponse: NetResponse? = nil) -> Builder {
        return Builder(netResponse)
    }

    public init(_ builder: Builder) {
        self.init(builder.url, mimeType: builder.mimeType, contentLength: builder.contentLength, textEncoding: builder.textEncoding, filename: builder.filename, statusCode: builder.statusCode, headers: builder.headers, localizedDescription: builder.localizedDescription, userInfo: builder.userInfo, netTask: builder.netTask, responseObject: builder.responseObject)
    }

}
