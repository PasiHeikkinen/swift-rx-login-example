import Foundation

extension DispatchTimeInterval {
    static func makeIncreasingRetryDelaySequence() -> AnySequence<DispatchTimeInterval> {
        return AnySequence(
            [
                AnySequence([1, 2, 3, 5, 8, 13, 21, 34].lazy.map(DispatchTimeInterval.seconds)),
                AnySequence(repeatElement(DispatchTimeInterval.seconds(34), count: Int.max).lazy)
            ]
            .joined()
        )
    }
}
