//
//  NetMultipartFormData.swift
//  Net
//
//  Created by Alex Rupérez on 27/4/17.
//
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

public class NetMultipartFormData {

    struct EncodingCharacters {
        static let crlf = "\r\n"
    }

    struct BoundaryGenerator {
        enum BoundaryType {
            case initial, encapsulated, final
        }

        static func randomBoundary() -> String {
            return String(format: "net.boundary.%08x%08x", arc4random(), arc4random())
        }

        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText: String

            switch boundaryType {
            case .initial:
                boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
            case .encapsulated:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
            case .final:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
            }

            return boundaryText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        }
    }

    class BodyPart {
        let headers: [String : String]
        let bodyStream: InputStream
        let bodyContentLength: UInt64
        var hasInitialBoundary = false
        var hasFinalBoundary = false

        init(headers: [String : String], bodyStream: InputStream, bodyContentLength: UInt64) {
            self.headers = headers
            self.bodyStream = bodyStream
            self.bodyContentLength = bodyContentLength
        }
    }

    /// The `Content-Type` header value containing the boundary used to generate the `multipart/form-data`.
    open var contentType: String { return "multipart/form-data; boundary=\(boundary)" }

    /// The content length of all body parts used to generate the `multipart/form-data` not including the boundaries.
    public var contentLength: UInt64 { return bodyParts.reduce(0) { $0 + $1.bodyContentLength } }

    /// The boundary used to separate the body parts in the encoded form data.
    public let boundary: String

    private var bodyParts: [BodyPart]
    private var bodyPartError: NetError?
    private let streamBufferSize: Int

    /// Creates a multipart form data object.
    ///
    /// - returns: The multipart form data object.
    public init() {
        self.boundary = BoundaryGenerator.randomBoundary()
        self.bodyParts = []
        self.streamBufferSize = 1024
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data: The data to encode into the multipart form data.
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header.
    public func append(_ data: Data, withName name: String) {
        let headers = contentHeaders(withName: name)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data:     The data to encode into the multipart form data.
    /// - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
    public func append(_ data: Data, withName name: String, mimeType: String) {
        let headers = contentHeaders(withName: name, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter data:     The data to encode into the multipart form data.
    /// - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the data in the `Content-Type` HTTP header.
    public func append(_ data: Data, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// The filename in the `Content-Disposition` HTTP header is generated from the last path component of the
    /// `fileURL`. The `Content-Type` HTTP header MIME type is generated by mapping the `fileURL` extension to the
    /// system associated MIME type.
    ///
    /// - parameter fileURL: The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:    The name to associate with the file content in the `Content-Disposition` HTTP header.
    public func append(_ fileURL: URL, withName name: String) {
        let fileName = fileURL.lastPathComponent
        let pathExtension = fileURL.pathExtension

        if !fileName.isEmpty && !pathExtension.isEmpty {
            let mime = mimeType(forPathExtension: pathExtension)
            append(fileURL, withName: name, fileName: fileName, mimeType: mime)
        } else {
            setBodyPartError("Body part filename is invalid.", object: fileURL, underlying: URLError(.fileDoesNotExist))
        }
    }

    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
    /// - Content-Type: #{mimeType} (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter fileURL:  The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:     The name to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the file content in the `Content-Type` HTTP header.
    public func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)

        guard fileURL.isFileURL else {
            setBodyPartError("Body part URL is invalid.", object: fileURL, underlying: URLError(.badURL))
            return
        }

        do {
            let isReachable = try fileURL.checkPromisedItemIsReachable()
            guard isReachable else {
                setBodyPartError("Body part file not reachable.", object: fileURL, underlying: URLError(.cannotOpenFile))
                return
            }
        } catch {
            setBodyPartError("Body part file not reachable.", object: fileURL, underlying: error)
            return
        }

        var isDirectory: ObjCBool = false
        let path = fileURL.path

        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue else {
            setBodyPartError("Body part file is directory.", object: fileURL, underlying: URLError(.fileIsDirectory))
            return
        }

        let bodyContentLength: UInt64

        do {
            guard let fileSize = try FileManager.default.attributesOfItem(atPath: path)[.size] as? NSNumber else {
                setBodyPartError("Body part file size not available.", object: fileURL, underlying: URLError(.noPermissionsToReadFile))
                return
            }

            bodyContentLength = fileSize.uint64Value
        } catch {
            setBodyPartError("Body part file size query failed.", object: fileURL, underlying: error)
            return
        }

        guard let stream = InputStream(url: fileURL) else {
            setBodyPartError("Body part input stream creation failed.", object: fileURL, underlying: URLError(.cannotCreateFile))
            return
        }

        append(stream, withLength: bodyContentLength, headers: headers)
    }

    /// Creates a body part from the stream and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded stream data
    /// - Multipart form boundary
    ///
    /// - parameter stream:   The input stream to encode in the multipart form data.
    /// - parameter length:   The content length of the stream.
    /// - parameter name:     The name to associate with the stream content in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the stream content in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the stream content in the `Content-Type` HTTP header.
    public func append(
        _ stream: InputStream,
        withLength length: UInt64,
        name: String,
        fileName: String,
        mimeType: String)
    {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part with the headers, stream and length and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - HTTP headers
    /// - Encoded stream data
    /// - Multipart form boundary
    ///
    /// - parameter stream:  The input stream to encode in the multipart form data.
    /// - parameter length:  The content length of the stream.
    /// - parameter headers: The HTTP headers for the body part.
    public func append(_ stream: InputStream, withLength length: UInt64, headers: [String : String]) {
        let bodyPart = BodyPart(headers: headers, bodyStream: stream, bodyContentLength: length)
        bodyParts.append(bodyPart)
    }

    // MARK: - Data Encoding

    /// Encodes all the appended body parts into a single `Data` value.
    ///
    /// It is important to note that this method will load all the appended body parts into memory all at the same
    /// time. This method should only be used when the encoded data will have a small memory footprint. For large data
    /// cases, please use the `writeEncodedDataToDisk(fileURL:completionHandler:)` method.
    ///
    /// - throws: An `AFError` if encoding encounters an error.
    ///
    /// - returns: The encoded `Data` if encoding is successful.
    public func encode() throws -> Data {
        if let bodyPartError = bodyPartError {
            throw bodyPartError
        }

        var encoded = Data()

        bodyParts.first?.hasInitialBoundary = true
        bodyParts.last?.hasFinalBoundary = true

        for bodyPart in bodyParts {
            let encodedData = try encode(bodyPart)
            encoded.append(encodedData)
        }

        return encoded
    }

    /// Writes the appended body parts into the given file URL.
    ///
    /// This process is facilitated by reading and writing with input and output streams, respectively. Thus,
    /// this approach is very memory efficient and should be used for large body part data.
    ///
    /// - parameter fileURL: The file URL to write the multipart form data into.
    ///
    /// - throws: An `AFError` if encoding encounters an error.
    public func writeEncodedData(to fileURL: URL) throws {
        if let bodyPartError = bodyPartError {
            throw bodyPartError
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            let underlying = URLError(.fileDoesNotExist)
            throw NetError.parse(code: underlying._code, message: "Output stream file already exists.", object: fileURL, underlying: underlying)
        } else if !fileURL.isFileURL {
            let underlying = URLError(.badURL)
            throw NetError.parse(code: underlying._code, message: "Output stream URL is invalid.", object: fileURL, underlying: underlying)
        }

        guard let outputStream = OutputStream(url: fileURL, append: false) else {
            let underlying = URLError(.cannotCreateFile)
            throw NetError.parse(code: underlying._code, message: "Output stream creation failed.", object: fileURL, underlying: underlying)
        }

        outputStream.open()
        defer { outputStream.close() }

        self.bodyParts.first?.hasInitialBoundary = true
        self.bodyParts.last?.hasFinalBoundary = true

        for bodyPart in self.bodyParts {
            try write(bodyPart, to: outputStream)
        }
    }

    private func encode(_ bodyPart: BodyPart) throws -> Data {
        var encoded = Data()

        let initialData = bodyPart.hasInitialBoundary ? initialBoundaryData() : encapsulatedBoundaryData()
        encoded.append(initialData)

        let headerData = encodeHeaders(for: bodyPart)
        encoded.append(headerData)

        let bodyStreamData = try encodeBodyStream(for: bodyPart)
        encoded.append(bodyStreamData)

        if bodyPart.hasFinalBoundary {
            encoded.append(finalBoundaryData())
        }

        return encoded
    }

    private func encodeHeaders(for bodyPart: BodyPart) -> Data {
        var headerText = ""

        for (key, value) in bodyPart.headers {
            headerText += "\(key): \(value)\(EncodingCharacters.crlf)"
        }
        headerText += EncodingCharacters.crlf

        return headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }

    private func encodeBodyStream(for bodyPart: BodyPart) throws -> Data {
        let inputStream = bodyPart.bodyStream
        inputStream.open()
        defer { inputStream.close() }

        var encoded = Data()

        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)

            if let streamError = inputStream.streamError {
                throw NetError.parse(code: streamError._code, message: "Input stream read failed.", object: inputStream, underlying: streamError)
            }

            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }

        return encoded
    }

    private func write(_ bodyPart: BodyPart, to outputStream: OutputStream) throws {
        try writeInitialBoundaryData(for: bodyPart, to: outputStream)
        try writeHeaderData(for: bodyPart, to: outputStream)
        try writeBodyStream(for: bodyPart, to: outputStream)
        try writeFinalBoundaryData(for: bodyPart, to: outputStream)
    }

    private func writeInitialBoundaryData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let initialData = bodyPart.hasInitialBoundary ? initialBoundaryData() : encapsulatedBoundaryData()
        return try write(initialData, to: outputStream)
    }

    private func writeHeaderData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let headerData = encodeHeaders(for: bodyPart)
        return try write(headerData, to: outputStream)
    }

    private func writeBodyStream(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let inputStream = bodyPart.bodyStream

        inputStream.open()
        defer { inputStream.close() }

        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)

            if let streamError = inputStream.streamError {
                throw NetError.parse(code: streamError._code, message: "Input stream read failed.", object: inputStream, underlying: streamError)
            }

            if bytesRead > 0 {
                if buffer.count != bytesRead {
                    buffer = Array(buffer[0..<bytesRead])
                }

                try write(&buffer, to: outputStream)
            } else {
                break
            }
        }
    }

    private func writeFinalBoundaryData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        if bodyPart.hasFinalBoundary {
            return try write(finalBoundaryData(), to: outputStream)
        }
    }

    private func write(_ data: Data, to outputStream: OutputStream) throws {
        var buffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        
        return try write(&buffer, to: outputStream)
    }
    
    private func write(_ buffer: inout [UInt8], to outputStream: OutputStream) throws {
        var bytesToWrite = buffer.count
        
        while bytesToWrite > 0, outputStream.hasSpaceAvailable {
            let bytesWritten = outputStream.write(buffer, maxLength: bytesToWrite)
            
            if let streamError = outputStream.streamError {
                throw NetError.parse(code: streamError._code, message: "Output stream write failed.", object: outputStream, underlying: streamError)
            }
            
            bytesToWrite -= bytesWritten
            
            if bytesToWrite > 0 {
                buffer = Array(buffer[bytesWritten..<buffer.count])
            }
        }
    }

    private func mimeType(forPathExtension pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }

    private func contentHeaders(withName name: String, fileName: String? = nil, mimeType: String? = nil) -> [String: String] {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName { disposition += "; filename=\"\(fileName)\"" }
        
        var headers = ["Content-Disposition": disposition]
        if let mimeType = mimeType { headers["Content-Type"] = mimeType }
        
        return headers
    }

    private func initialBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary)
    }
    
    private func encapsulatedBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .encapsulated, boundary: boundary)
    }
    
    private func finalBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary)
    }

    private func setBodyPartError(_ reason: String, object: Any?, underlying: Error?) {
        guard bodyPartError == nil else {
            return
        }
        bodyPartError = NetError.parse(code: underlying?._code, message: reason, object: object, underlying: underlying)
    }


}
