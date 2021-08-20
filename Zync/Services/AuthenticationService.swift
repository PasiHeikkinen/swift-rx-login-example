import Foundation
import RxSwift

struct Credentials: Equatable {
    let username: String
    let password: String

    var isValid: Bool {
        !(username.isEmpty || password.isEmpty)
    }
}

struct AuthenticationToken {
    let value: String
}

protocol AuthenticationService {
    func authenticate(credentials: Credentials) -> Single<AuthenticationToken>
}

enum AuthenticationError: Error {
    case invalidUsernameOrPassword

    var localizedDescription: String {
        switch self {
        case .invalidUsernameOrPassword:
            return "Invalid username or password"
        }
    }
}

class DefaultAuthenticationService: AuthenticationService {
    func authenticate(credentials: Credentials) -> Single<AuthenticationToken> {
        return Single
            .deferred {
                if credentials == .init(username: "jimmy", password: "password1") {
                    return .just(.init(value: "123"))
                        .delay(.seconds(1), scheduler: MainScheduler.instance)
                } else {
                    return Single.just(())
                        .delay(.seconds(1), scheduler: MainScheduler.instance)
                        .asCompletable()
                        .andThen(.error(AuthenticationError.invalidUsernameOrPassword))
                }
            }

    }
}
