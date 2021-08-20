import Foundation
import RxSwift

extension ObservableConvertibleType {
    func asyncValues<Output>(
        makeOutput: @escaping (Element) -> Single<Output>
    ) -> Observable<AsyncValueState<Output>> {
        return asObservable().flatMapLatest { input in
            return makeOutput(input).asyncValues()
        }
    }
}

extension ObservableConvertibleType {
    func asyncValues<Output>(
        makeOutput: @escaping (Element) -> Single<Output>,
        isRetryable: @escaping (Error) -> Bool,
        retries: @escaping (Observable<Error>) -> Observable<Void> = { $0.defaultRetries() }
    ) -> Observable<AsyncValueState<Output>> {
        return asObservable().flatMapLatest { input in
            return makeOutput(input).asyncValues(isRetryable: isRetryable, retries: retries)
        }
    }
}
