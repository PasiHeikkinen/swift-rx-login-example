import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    static func from<Error>(result: Result<Element, Error>) -> Self {
        switch result {
        case .success(let value):
            return .just(value)
        case .failure(let error):
            return .error(error)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    func unwrapResult<Value, Error>() -> Single<Value> where Element == Result<Value, Error> {
        return flatMap({ (result) -> Single<Value> in
            return Single<Value>.from(result: result)
        })
    }
}
