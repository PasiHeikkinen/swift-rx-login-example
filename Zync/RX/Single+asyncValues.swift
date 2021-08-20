import Foundation
import RxSwift

extension Single {
    func asyncValues(
        isRetryable: @escaping (Error) -> Bool,
        retries: @escaping (Observable<Error>) -> Observable<Void> = { $0.defaultRetries() }
    ) -> Observable<AsyncValueState<Element>> {
        return self.asObservable()
            .wrapResult()
            .passErrorResultAndUnwrap()
            .wrapAffixed()
            .retry(when: { (errors: Observable<Error>) -> Observable<Void> in
                return retries(errors.take(while: isRetryable))
            })
            .flattenToAsyncValueState(isRetryable: isRetryable)
    }
}

extension Single {
    func asyncValues() -> Observable<AsyncValueState<Element>> {
        return asObservable()
            .wrapResult()
            .wrapAffixed()
            .flattenToAsyncValueState()
    }
}
