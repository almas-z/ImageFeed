import Foundation

// MARK: - HTTP Method Enum

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

// MARK: - OAuth2Service

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard lastCode != code else {
            print("🔁 Повторный запрос с тем же кодом — отменяем.")
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(with: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("🌐 Отправляем запрос на получение токена...")
        task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }
            self.task = nil
            
            switch result {
            case .success(let data):
                do {
                    print("📦 Ответ от сервера: \(String(data: data, encoding: .utf8) ?? "—")")
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = tokenResponse.accessToken
                    self.tokenStorage.token = accessToken
                    print("✅ Токен успешно получен и сохранён.")
                    completion(.success(accessToken))
                } catch {
                    print("❌ Ошибка декодирования токена: \(error)")
                    completion(.failure(NetworkError.decodingError))
                }
                
            case .failure(let error):
                print("❌ Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(with code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let body = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        return request
    }
    
    // MARK: - Models
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
