import Foundation
import RxSwift

extension Observable {
    func flatMapAsyncValue<V, R>(_ f: @escaping (V) -> Observable<AsyncValueState<R>>) -> Observable<AsyncValueState<R>> where Element == AsyncValueState<V> {
        return flatMap { element -> Observable<AsyncValueState<R>> in
            switch element {
            case .loading(let error):
                return .just(.loading(error))
            case .success(let value):
                return f(value)
            case .failure(let error):
                return .just(.failure(error))
            }
        }
    }
}
