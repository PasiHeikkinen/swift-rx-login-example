import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel(service: DefaultAuthenticationService())
    private let disposeBag = DisposeBag()

    override func loadView() {
        view = LoginView()
    }

    private var loginView: LoginView {
        view as! LoginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.bind(to: loginView).disposed(by: disposeBag)

        viewModel.autheticationSucceded
            .emit(with: self) { controller, token in
                let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                controller.present(alert, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

fileprivate extension LoginViewModel {
    func bind(to view: LoginView) -> Disposable {
        var disposables: [Disposable] = []

        // View -> View Model:
        disposables.append(view.usernameField.rx.text.asObservable().bind(to: self.username(observable:)))
        disposables.append(view.passwordField.rx.text.asObservable().bind(to: self.password(observable:)))
        disposables.append(view.loginButton.rx.tap.bind(to: self.loginTapped(observable:)))

        // View Model -> View
        disposables.append(self.isButtonEnabled.drive(view.loginButton.rx.isEnabled))
        disposables.append(self.isButtonHidden.drive(view.loginButton.rx.isHidden))

        disposables.append(self.isUsernameFieldEnabled.drive(view.usernameField.rx.isEnabled))
        disposables.append(self.isPasswordFieldEnabled.drive(view.passwordField.rx.isEnabled))
        disposables.append(self.errorMessage.drive(view.errorMessageLabel.rx.text))

        disposables.append(self.isActivityIndicatorAnimating.drive(view.activityIndicatorView.rx.isAnimating))

        return Disposables.create(disposables)
    }
}

private final class LoginView: UIView {
    let usernameField = using(UITextField()) {
        $0.placeholder = "Username"
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
    }
    let passwordField = using(UITextField()) {
        $0.isSecureTextEntry = true
        $0.placeholder = "Password"
    }

    let loginButton = using(UIButton(type: .custom)) {
        $0.setTitle("Login", for: [.normal])
        $0.setTitleColor(.systemBlue, for: [.normal])
        $0.setTitleColor(.systemGray, for: [.disabled])
    }
    let errorMessageLabel = using(UILabel()) {
        $0.numberOfLines = 0
    }
    let activityIndicatorView = using(UIActivityIndicatorView(style: .large)) { _ in
    }

    init() {
        super.init(frame: .zero)

        layoutMargins = .init(top: 32, left: 48, bottom: 32, right: 48)
        backgroundColor = .white

        addSubview(usernameField)
        addSubview(passwordField)
        addSubview(loginButton)
        addSubview(errorMessageLabel)
        addSubview(activityIndicatorView)

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)

        layoutGuide.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        usernameField.snp.makeConstraints { make in
            make.top.equalTo(layoutGuide)
            make.leading.equalTo(snp.leadingMargin)
            make.trailing.equalTo(snp.trailingMargin)
        }

        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(8)
            make.leading.equalTo(snp.leadingMargin)
            make.trailing.equalTo(snp.trailingMargin)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.leading.equalTo(snp.leadingMargin)
            make.trailing.equalTo(snp.trailingMargin)
        }

        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalTo(loginButton)
        }

        errorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.leading.equalTo(snp.leadingMargin)
            make.trailing.equalTo(snp.trailingMargin)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
