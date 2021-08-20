import Foundation
import RxSwift

extension Observable {
    /// Delays emitting values from the source observable using delays from the given sequence.
    ///
    /// The returned observable completes if all delays have been used. It is safe and recommended
    /// to provide delays as a lazy sequence. This way the sequence can be infinite.
    ///
    /// - Parameters:
    ///   - delays: the sequnce of delays
    ///   - scheduler: the scheduler running timers for delays
    /// - Returns: An observable sequnce where nth element is delayd by nth time interval from the provides delay sequence.
    func delayed<S: Sequence>(delays: S, scheduler: SchedulerType) -> Observable<Element> where S.Element == DispatchTimeInterval {
        return self
            .scan(into: DelayState(iterator: AnyIterator(delays.makeIterator()))) { source, element in
                source.next(element: element)
            }
            .take(while: { (state) -> Bool in
                !state.state.isEnd
            })
            .flatMapLatest { source -> Observable<Element> in
                guard case .delayedElement(let delay, let value) = source.state else {
                    return .empty()
                }
                return Observable<Int>.timer(delay, scheduler: scheduler).map { _ in value }
            }
    }
}

private struct DelayState<Element> {
    var iterator: AnyIterator<DispatchTimeInterval>
    var state: State = .initial

    enum State {
        case initial
        case delayedElement(DispatchTimeInterval, Element)
        case end

        var isEnd: Bool {
            if case .end = self {
                return true
            } else {
                return false
            }
        }
    }

    mutating func next(element: Element) {
        guard let head = iterator.next() else {
            state = .end
            return
        }
        state = .delayedElement(head, element)
    }
}
