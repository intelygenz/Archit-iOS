//
//  NetReachability.swift
//  Net
//
//  Created by Alex Rupérez on 25/4/17.
//
//

#if !os(watchOS)
import SystemConfiguration

public class NetReachability {

    public enum Connection {
        case ethernetOrWiFi, wwan
    }

    public enum Status {
        case unknown, unreachable, reachable(Connection)
    }

    public typealias ReachabilityClosure = (Status) -> Swift.Void

    public static let shared = NetReachability()

    public var reachable: Bool { return reachableWWAN || reachableEthernetOrWiFi }

    public var reachableWWAN: Bool { return current == .reachable(.wwan) }

    public var reachableEthernetOrWiFi: Bool { return current == .reachable(.ethernetOrWiFi) }

    public var queue = DispatchQueue.main

    public var listener: ReachabilityClosure?

    public var current: Status {
        guard let flags = self.flags else {
            return .unknown
        }
        return status(flags)
    }

    private var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else {
            return nil
        }
        return flags
    }

    private let reachability: SCNetworkReachability
    private var previous: SCNetworkReachabilityFlags

    public convenience init?() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &address, { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return nil
        }

        self.init(reachability)
    }

    public convenience init?(_ host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            return nil
        }

        self.init(reachability)
    }

    private init(_ reachability: SCNetworkReachability) {
        self.reachability = reachability
        self.previous = SCNetworkReachabilityFlags()
    }

    deinit {
        stop()
        listener = nil
    }

    @discardableResult public func start() -> Bool {
        var context = SCNetworkReachabilityContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        let callbackEnabled = SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
                let reachability = Unmanaged<NetReachability>.fromOpaque(info!).takeUnretainedValue()
                reachability.notify(flags)
        }, &context)

        let queueEnabled = SCNetworkReachabilitySetDispatchQueue(reachability, queue)

        queue.async {
            self.previous = SCNetworkReachabilityFlags()
            self.notify(self.flags ?? SCNetworkReachabilityFlags())
        }

        return callbackEnabled && queueEnabled
    }

    public func stop() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    func notify(_ flags: SCNetworkReachabilityFlags) {
        guard previous != flags else {
            return
        }

        previous = flags
        listener?(status(flags))
    }

    func status(_ flags: SCNetworkReachabilityFlags) -> Status {
        guard flags.contains(.reachable) else {
            return .unreachable
        }

        var networkStatus: Status = .unreachable

        if !flags.contains(.connectionRequired) {
            networkStatus = .reachable(.ethernetOrWiFi)
        }

        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
            if !flags.contains(.interventionRequired) {
                networkStatus = .reachable(.ethernetOrWiFi)
            }
        }

        #if os(iOS)
        if flags.contains(.isWWAN) {
            networkStatus = .reachable(.wwan)
        }
        #endif

        return networkStatus
    }

}

extension NetReachability.Status: Equatable {

    public static func ==(lhs: NetReachability.Status, rhs: NetReachability.Status) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.unreachable, .unreachable):
            return true
        case let (.reachable(lhsConnectionType), .reachable(rhsConnectionType)):
            return lhsConnectionType == rhsConnectionType
        default:
            return false
        }
    }

}

extension NetReachability.Status: CustomStringConvertible {

    public var description: String {
        switch self {
        case .reachable(let connection):
            return "Reachable: \(connection)"
        case .unreachable:
            return "Unreachable"
        default:
            return "Unknown"
        }
    }
    
}

extension NetReachability.Status: CustomDebugStringConvertible {

    public var debugDescription: String {
        return description
    }

}

extension NetReachability.Connection: CustomStringConvertible {

    public var description: String {
        switch self {
        case .ethernetOrWiFi:
            return "Ethernet/WiFi"
        default:
            return "WWAN"
        }
    }
    
}

extension NetReachability.Connection: CustomDebugStringConvertible {

    public var debugDescription: String {
        return description
    }

}
#endif
