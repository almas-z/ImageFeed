import UIKit

// MARK: - Delegate Protocol

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private let showWebViewSegueID = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueID,
              let webViewViewController = segue.destination as? WebViewViewController else {
            super.prepare(for: segue, sender: sender)
            return
        }
        webViewViewController.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func authenticateUser(withCode token: String) {
        OAuth2TokenStorage.shared.token = token
        
        guard let window = UIApplication.shared.windows.first else {
            print("Ошибка: не удалось получить окно приложения")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                print("Успешно получен токен: \(token)")
                self?.authenticateUser(withCode: token)
            case .failure(let error):
                print("Ошибка при получении токена: \(error.localizedDescription)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
