import Foundation
import RxSwift

enum Affixed<Value> {
    case start
    case value(Value)
    case end

    var isInProgress: Bool {
        switch self {
        case .start, .value:
            return true
        case .end:
            return false
        }
    }

    var isEnd: Bool {
        switch self {
        case .end:
            return true
        case .start, .value:
            return false
        }
    }

    var value: Value? {
        if case .value(let result) = self {
            return result
        } else {
            return nil
        }
    }
}

extension ObservableType {
    /// Adds extra start and end values to the observable. A common use for this is for communicating progress.
    ///
    /// Emitted values:
    ///  * `Affixed.start` when the observable is subscribed to and before any other values are emitted.
    ///  * `Affixed.end` before the observable completes or errors
    ///  * `Affixed.value` for each value emitted by the source observable.
    /// - Returns: a new observable with extra affixed values
    func wrapAffixed() -> Observable<Affixed<Element>> {
        return map(Affixed.value)
            .startWith(Affixed.start)
            .concat(Observable<Affixed>.just(.end))
            .catch { (error) -> Observable<Affixed<Self.Element>> in
                return Observable.error(error).startWith(.end)
            }
    }
}

extension ObservableType {
    /// Emits only source values of the source observable.
    ///
    /// - Returns: a new observable emitting only source values
    func unwrapAffixed<Value>() -> Observable<Value> where Element == Affixed<Value> {
        return compactMap { $0.value }
    }
}
