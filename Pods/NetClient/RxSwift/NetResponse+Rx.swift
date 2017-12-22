//
//  NetResponse+Rx.swift
//  Net
//
//  Created by Alejandro Ruperez Hernando on 20/12/17.
//

import Foundation
import RxSwift

extension ObservableType where E == NetResponse {

    public func object<T>() throws -> Observable<T> {
        return flatMap {
            return Observable.just(try $0.object())
        }
    }

    public func decode<D: Decodable>() -> Observable<D> {
        return flatMap {
            return Observable.just(try $0.decode())
        }
    }

}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == NetResponse {

    public func object<T>() throws -> Single<T> {
        return flatMap {
            return Single.just(try $0.object())
        }
    }

    public func decode<D: Decodable>() -> Single<D> {
        return flatMap {
            return Single.just(try $0.decode())
        }
    }

}
