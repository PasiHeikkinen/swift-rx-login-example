import Foundation
import RxSwift

extension PrimitiveSequence where Trait == MaybeTrait {
    static func from<T>(affixedResult: Affixed<Result<T, Error>>, isRetryable: (Error) -> Bool) -> Maybe<AsyncValueState<T>> {
        switch affixedResult {
        case .start:
            return .just(.loading(nil))
        case .value(let result):
            switch result {
            case .success(let value):
                return .just(.success(value))
            case .failure(let error):
                if isRetryable(error) {
                    return .just(.loading(error))
                } else {
                    return .just(.failure(error))
                }
            }
        case .end:
            return .empty()
        }
    }

    static func from<T>(affixedResult: Affixed<Result<T, Error>>) -> Maybe<AsyncValueState<T>> {
        switch affixedResult {
        case .start:
            return .just(.loading(nil))
        case .value(let result):
            switch result {
            case .success(let value):
                return .just(.success(value))
            case .failure(let error):
                return .just(.failure(error))
            }
        case .end:
            return .empty()
        }
    }
}
