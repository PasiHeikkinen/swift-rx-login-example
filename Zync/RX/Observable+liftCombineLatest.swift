import Foundation
import RxSwift

func lift<P1, R>(_ f: @escaping (P1) -> R) -> (Observable<P1>) -> Observable<R> {
    return { $0.map(f) }
}

func liftCombineLatest<P1, P2, R>(_ f: @escaping (P1, P2) -> R) -> (Observable<P1>, Observable<P2>) -> Observable<R> {
    return {
        Observable.combineLatest($0, $1, resultSelector: f)
    }
}

func liftCombineLatest<P1, P2, P3, R>(_ f: @escaping (P1, P2, P3) -> R) -> (Observable<P1>, Observable<P2>, Observable<P3>) -> Observable<R> {
    return {
        Observable.combineLatest($0, $1, $2, resultSelector: f)
    }
}
