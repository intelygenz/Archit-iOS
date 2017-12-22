//
//  NetTask+Rx.swift
//  Net
//
//  Created by Alex Rupérez on 19/12/17.
//

import Foundation
import RxSwift

extension NetTask: ReactiveCompatible {}

extension Reactive where Base: NetTask {

    public func response() -> Single<NetResponse> {
        return Single.create { single in
            let task = self.base.async({ (response, error) in
                if let response = response, error == nil {
                    single(.success(response))
                } else if let error = error {
                    single(.error(error))
                }
            })
            return Disposables.create(with: task.cancel)
        }
    }

    public func progress() -> Observable<Progress> {
        return Observable.create { observer in
            self.base.progress({ progress in
                observer.on(.next(progress))
                if progress.totalUnitCount > 0, progress.completedUnitCount >= progress.totalUnitCount {
                    observer.on(.completed)
                }
            })
            return Disposables.create()
        }
    }

}
