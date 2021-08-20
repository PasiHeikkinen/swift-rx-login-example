import Foundation
import RxSwift

extension Observable where Element == Error {
    func defaultRetries() -> Observable<Void> {
        let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "retry")
        return self
            .delayed(
                delays: DispatchTimeInterval.makeIncreasingRetryDelaySequence(),
                scheduler: scheduler
            )
            .map { _ in () }
    }
}
