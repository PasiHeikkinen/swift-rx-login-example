import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    private let usernameSubject = BehaviorSubject<String?>(value: nil)
    private let passwordSubject = BehaviorSubject<String?>(value: nil)
    
    private let loginRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    let isInProgress: Driver<Bool>

    let isUsernameFieldEnabled: Driver<Bool>
    let isPasswordFieldEnabled: Driver<Bool>
    let isButtonEnabled: Driver<Bool>
    let isButtonHidden: Driver<Bool>
    let errorMessage: Driver<String?>
    let isActivityIndicatorAnimating: Driver<Bool>
    let autheticationSucceded: Signal<AuthenticationToken>

    init(service: AuthenticationService) {
        let makeCredentials  = liftCombineLatest(Credentials.init(username:password:))
        let credentials = makeCredentials(
            usernameSubject.map { $0 ?? "" },
            passwordSubject.map { $0 ?? "" }
        )

        let loginAsyncValue = loginRelay.withLatestFrom(credentials)
            .asyncValues(makeOutput: service.authenticate(credentials:))
            .share(replay: 1, scope: .whileConnected)

        errorMessage = loginAsyncValue
            .map { value in
                switch value {
                case .loading(_):
                    return nil
                case .success(_):
                    return nil
                case .failure(let error):
                    if let error = error as? AuthenticationError {
                        return error.localizedDescription
                    } else {
                        return error.localizedDescription
                    }
                }
            }
            .asDriver(onErrorDriveWith: .empty())

        isInProgress = loginAsyncValue
            .map { $0.isLoading }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())

        let isInputEnabled = isInProgress.map(!)
        isUsernameFieldEnabled = isInputEnabled
        isPasswordFieldEnabled = isInputEnabled
        isButtonEnabled = Driver
            .combineLatest(
                [
                    isInputEnabled,
                    credentials.map { $0.isValid }.asDriver(onErrorDriveWith: .empty())
                ]
            )
            .map { $0.allSatisfy { $0 }}
        isButtonHidden = isInProgress
        isActivityIndicatorAnimating = isInProgress

        autheticationSucceded = loginAsyncValue
            .compactMap { $0.value }
            .asSignal(onErrorSignalWith: .empty())
    }

    func username(observable: Observable<String?>) -> Disposable {
        return observable.bind(to: usernameSubject)
    }

    func password(observable: Observable<String?>) -> Disposable {
        return observable.bind(to: passwordSubject)
    }

    func loginTapped(observable: ControlEvent<Void>)  -> Disposable {
        return observable.bind(to: loginRelay)
    }
}
