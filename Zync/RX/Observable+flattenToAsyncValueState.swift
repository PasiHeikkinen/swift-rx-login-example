import Foundation
import RxSwift

extension Observable {
    func flattenToAsyncValueState<T>() -> Observable<AsyncValueState<T>> where Element == Affixed<Result<T, Error>> {
        return flatMap { Maybe<AsyncValueState<T>>.from(affixedResult: $0) }
            .distinctUntilChanged { lhs, rhs in
                // Keep AsyncValueState.loading with error value instead of no error:
                if case (.loading(let lhsError), (.loading(let rhsError))) = (lhs, rhs), lhsError != nil && rhsError == nil {
                    return true
                }
                return false
            }
    }

    func flattenToAsyncValueState<T>(isRetryable: @escaping (Error) -> Bool) -> Observable<AsyncValueState<T>> where Element == Affixed<Result<T, Error>> {
        return flatMap { Maybe<AsyncValueState<T>>.from(affixedResult: $0, isRetryable: isRetryable) }
            .distinctUntilChanged { lhs, rhs in
                // Keep AsyncValueState.loading with error value instead of no error:
                if case (.loading(let lhsError), (.loading(let rhsError))) = (lhs, rhs), lhsError != nil && rhsError == nil {
                    return true
                }
                return false
            }
    }
}
