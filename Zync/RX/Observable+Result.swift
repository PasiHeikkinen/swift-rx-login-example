import Foundation
import RxSwift

extension ObservableType {
    func onlySuccessValues<Value, Error>() -> Observable<Value> where Element == Result<Value, Error> {
        return compactMap { result in
            switch result {
            case .success(let value):
                return value
            case .failure:
                return nil
            }
        }
    }

    func onlyFailureErrors<Value, Error>() -> Observable<Error> where Element == Result<Value, Error> {
        return compactMap { result in
            switch result {
            case .success:
                return nil
            case .failure(let error):
                return error
            }
        }
    }
}

extension Observable {
    func wrapResult() -> Observable<Result<Element, Error>> {
        return self
            .map(Result.success)
            .catch { (error) -> Observable<Result<Element, Error>> in
                return .just(.failure(error))
            }
    }
}

extension ObservableType {
    func unwrapResult<WrappedElement>() -> Observable<WrappedElement> where Self.Element == Result<WrappedElement, Error> {
        return self.flatMap(Single.from(result:))
    }
}

extension ObservableType {
    /// Emits all result elements and after emitting a `.failure` emits the unwrapped error from the failure
    ///
    /// This is useful when you want to pass  the failure along first and then handle the error using RX error handling
    ///
    /// - Returns: an observable of results
    func passErrorResultAndUnwrap<T>() -> Observable<Element> where Element == Result<T, Error> {
        return self
            .flatMap { (result) -> Observable<Element> in
                switch result {
                case .success:
                    return .just(result)
                case .failure(let error):
                    return Observable.just(result).concat(Observable.error(error))
                }
            }
    }
}
