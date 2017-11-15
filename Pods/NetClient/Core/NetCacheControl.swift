//
//  NetCacheControl.swift
//  Net
//
//  Created by Alex Rupérez on 23/3/17.
//
//

import Foundation

public enum NetCacheControl {
    case maxAge(TimeInterval), maxStale(TimeInterval?), minFresh(TimeInterval), noCache, noStore, noTransform, onlyIfCached, custom(String)
}

extension NetCacheControl: Equatable {}

extension NetCacheControl: RawRepresentable {

    private struct StringValue {
        static let maxAge = "max-age"
        static let maxStale = "max-stale"
        static let minFresh = "min-fresh"
        static let noCache = "no-cache"
        static let noStore = "no-store"
        static let noTransform = "no-transform"
        static let onlyIfCached = "only-if-cached"
    }

    public typealias RawValue = String

    public init(rawValue: RawValue) {
        if rawValue.hasPrefix(StringValue.maxAge), let timeInterval = TimeInterval(rawValue[rawValue.index(StringValue.maxAge.endIndex, offsetBy: 1)...]) {
            self = .maxAge(timeInterval)
        } else if rawValue.hasPrefix(StringValue.maxStale) {
            if rawValue.count > StringValue.maxStale.count + 1 {
                self = .maxStale(TimeInterval(rawValue[rawValue.index(StringValue.maxStale.endIndex, offsetBy: 1)...]))
            } else {
                self = .maxStale(nil)
            }
        } else if rawValue.hasPrefix(StringValue.minFresh), let timeInterval = TimeInterval(rawValue[rawValue.index(StringValue.minFresh.endIndex, offsetBy: 1)...]) {
            self = .minFresh(timeInterval)
        } else if rawValue == StringValue.noCache {
            self = .noCache
        } else if rawValue == StringValue.noStore {
            self = .noStore
        } else if rawValue == StringValue.noTransform {
            self = .noTransform
        } else if rawValue == StringValue.onlyIfCached {
            self = .onlyIfCached
        } else {
            self = .custom(rawValue)
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .maxAge(let timeInterval):
            guard let intValue = Int(exactly: Double(timeInterval)) else {
                return "\(StringValue.maxAge)=\(timeInterval)"
            }
            return "\(StringValue.maxAge)=\(intValue)"
        case .maxStale(let timeInterval):
            guard let timeInterval = timeInterval else {
                return StringValue.maxStale
            }
            guard let intValue = Int(exactly: Double(timeInterval)) else {
                return "\(StringValue.maxStale)=\(timeInterval)"
            }
            return "\(StringValue.maxStale)=\(intValue)"
        case .minFresh(let timeInterval):
            guard let intValue = Int(exactly: Double(timeInterval)) else {
                return "\(StringValue.minFresh)=\(timeInterval)"
            }
            return "\(StringValue.minFresh)=\(intValue)"
        case .noCache:
            return StringValue.noCache
        case .noStore:
            return StringValue.noStore
        case .noTransform:
            return StringValue.noTransform
        case .onlyIfCached:
            return StringValue.onlyIfCached
        case .custom(let cacheControl):
            return cacheControl
        }
    }

}
