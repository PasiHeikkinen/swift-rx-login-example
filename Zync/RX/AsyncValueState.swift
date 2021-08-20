import Foundation
import RxSwift

/// A wrapper for a value that is loaded asynchronous.
///
/// In addition to available value provides an explicit `loading` state for the case when the value
/// is being produced asynchronously and the last seen error if loading failed.
enum AsyncValueState<T> {
    case loading(Error?)
    case success(T)
    case failure(Error)

    var value: T? {
        if case .success(let value) = self {
            return value
        } else {
            return nil
        }
    }

    var error: Error? {
        switch self {
        case .loading(let error):
            return error
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }

    var loadingError: Error? {
        if case .loading(let error) = self {
            return error
        } else {
            return nil
        }
    }

    var failureError: Error? {
        if case .failure(let error) = self {
            return error
        } else {
            return nil
        }
    }

    func map<R>(_ f: (T) -> R) -> AsyncValueState<R> {
        switch self {
        case .loading(let error):
            return .loading(error)
        case .success(let value):
            return .success(f(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension AsyncValueState {
    func mapObservable<R>(_ transform: @escaping (T) -> Observable<AsyncValueState<R>>) -> Observable<AsyncValueState<R>> {
        switch self {
        case .loading(let error):
            return .just(.loading(error))
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .just(.failure(error))
        }
    }
}
