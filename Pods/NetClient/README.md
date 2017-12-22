<p align="center">
  <img src="https://github.com/intelygenz/NetClient-iOS/raw/develop/Logo.png">
</p>

[![Twitter](https://img.shields.io/badge/contact-@intelygenz-0FABFF.svg?style=flat)](http://twitter.com/intelygenz)
[![Version](https://img.shields.io/cocoapods/v/NetClient.svg?style=flat)](http://cocoapods.org/pods/NetClient)
[![License](https://img.shields.io/cocoapods/l/NetClient.svg?style=flat)](http://cocoapods.org/pods/NetClient)
[![Platform](https://img.shields.io/cocoapods/p/NetClient.svg?style=flat)](http://cocoapods.org/pods/NetClient)
[![Swift](https://img.shields.io/badge/Swift-4-orange.svg?style=flat)](https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Build Status](https://travis-ci.org/intelygenz/NetClient-iOS.svg?branch=master)](https://travis-ci.org/intelygenz/NetClient-iOS)

**Net** is a versatile HTTP networking library written in Swift.

## 🌟 Features

- [x] URL / JSON / Property List Parameter Encoding
- [x] Upload File / Data / Stream / Multipart Form Data
- [x] Download File using Request or Resume Data
- [x] Authentication with URLCredential
- [x] Basic, Bearer and Custom Authorization Handling
- [x] Default and Custom Cache Controls
- [x] Default and Custom Content Types
- [x] Upload and Download Progress Closures with Progress
- [x] cURL Command Debug Output
- [x] Request and Response Interceptors
- [x] Asynchronous and synchronous task execution
- [x] Inference of response object type
- [x] Network reachability
- [x] TLS Certificate and Public Key Pinning
- [x] Retry requests
- [x] Codable / Decodable / Encodable protocols compatible (JSON / Property List)
- [x] watchOS Compatible
- [x] tvOS Compatible
- [x] macOS Compatible
- [x] [Alamofire](https://github.com/Alamofire/Alamofire) Implementation
- [x] [Moya](https://github.com/Moya/Moya)Provider Extension
- [x] [Kommander](https://github.com/intelygenz/Kommander-iOS) Extension
- [x] [RxSwift](https://github.com/ReactiveX/RxSwift) Extension

## 📋 Requirements

- iOS 8.0+ / macOS 10.9+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.0+
- Swift 4.0+

## 📲 Installation

Net is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NetClient'
```

For Swift 3 compatibility use:

```ruby
pod 'NetClient', '~> 0.2'
```

#### Or you can install it with [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "intelygenz/NetClient-iOS"
```

#### Or install it with [Swift Package Manager](https://swift.org/package-manager/):

```swift
dependencies: [
    .package(url: "https://github.com/intelygenz/NetClient-iOS.git")
]
```

## 🐒 Usage

### Build a NetRequest

```swift
import Net

do {
    let request = try NetRequest.builder("YOUR_URL")!
                .setAccept(.json)
                .setCache(.reloadIgnoringLocalCacheData)
                .setMethod(.PATCH)
                .setTimeout(20)
                .setJSONBody(["foo", "bar"])
                .setContentType(.json)
                .setServiceType(.background)
                .setCacheControls([.maxAge(500)])
                .setURLParameters(["foo": "bar"])
                .setAcceptEncodings([.gzip, .deflate])
                .setBasicAuthorization(user: "user", password: "password")
                .setHeaders(["foo": "bar"])
                .build()
} catch {
    print("Request error: \(error)")
}
```

### Request asynchronously

```swift
import Net

let net = NetURLSession()

net.data(URL(string: "YOUR_URL")!).async { (response, error) in
    do {
        if let object: [AnyHashable: Any] = try response?.object() {
            print("Response dictionary: \(object)")
        } else if let error = error {
            print("Net error: \(error)")
        }
    } catch {
        print("Parse error: \(error)")
    }
}
```

### Request synchronously

```swift
import Net

let net = NetURLSession()

do {
    let object: [AnyHashable: Any] = try net.data("YOUR_URL").sync().object()
    print("Response dictionary: \(object)")
} catch {
    print("Error: \(error)")
}
```

### Request from cache

```swift
import Net

let net = NetURLSession()

do {
    let object: [AnyHashable: Any] = try net.data("YOUR_URL").cached().object()
    print("Response dictionary: \(object)")
} catch {
    print("Error: \(error)")
}
```

### Track progress

```swift
import Net

let net = NetURLSession()

do {
    let task = try net.data("YOUR_URL").progress({ progress in
        print(progress)
    }).sync()
} catch {
    print("Error: \(error)")
}
```

### Add interceptors for all requests

```swift
import Net

let net = NetURLSession()

net.addRequestInterceptor { request in
    request.addHeader("foo", value: "bar")
    request.setBearerAuthorization(token: "token")
    return request
}
```

### Retry requests

```swift
import Net

let net = NetURLSession()

net.retryClosure = { response, _, _ in response?.statusCode == XXX }

do {
    let task = try net.data("YOUR_URL").retry({ response, error, retryCount in
        return retryCount < 2
    }).sync()
} catch {
    print("Error: \(error)")
}
```

## 🧙‍♂️ Codable

### Encodable

```swift
import Net

let request = NetRequest.builder("YOUR_URL")!
            .setJSONObject(Encodable())
            .build()
```

### Decodable

```swift
import Net

let net = NetURLSession()

do {
    let object: Decodable = try net.data("YOUR_URL").sync().decode()
    print("Response object: \(object)")
} catch {
    print("Error: \(error)")
}
```

## 🤝 Integrations

### Love [Alamofire](https://github.com/Alamofire/Alamofire)?

```ruby
pod 'NetClient/Alamofire'
```

```swift
import Net

let net = NetAlamofire()

...
```

### Love [Moya](https://github.com/Moya/Moya)?

```ruby
pod 'NetClient/Moya'
```

```swift
import Net
import Moya

let request = NetRequest("YOUR_URL")!
let provider = MoyaProvider<NetRequest>()
provider.request(request) { result in
    switch result {
    case let .success(response):
        print("Response: \(response)")
    case let .failure(error):
        print("Error: \(error)")
    }
}
```

### Love [Kommander](https://github.com/intelygenz/Kommander-iOS)?

```ruby
pod 'NetClient/Kommander'
```

```swift
import Net
import Kommander

let net = NetURLSession()
let kommander = Kommander.default

net.data(URL(string: "YOUR_URL")!).execute(by: kommander, onSuccess: { object in
    print("Response dictionary: \(object as [AnyHashable: Any])")
}) { error in
    print("Error: \(String(describing: error?.localizedDescription))")
}

net.data(URL(string: "YOUR_URL")!).executeDecoding(by: kommander, onSuccess: { object in
	print("Response object: \(object as Decodable)")
}) { error in
    print("Error: \(String(describing: error?.localizedDescription))")
}
```

### Love [RxSwift](https://github.com/ReactiveX/RxSwift)?

```ruby
pod 'NetClient/RxSwift'
```

```swift
import Net
import RxSwift

let request = NetRequest("YOUR_URL")!
_ = net.data(request).rx.response().observeOn(MainScheduler.instance).subscribe { print($0) }
```

## ❤️ Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## 👨‍💻 Authors

[alexruperez](https://github.com/alexruperez), alejandro.ruperez@intelygenz.com

## 👮‍♂️ License

Net is available under the MIT license. See the LICENSE file for more info.
