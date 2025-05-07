import Foundation

enum Constants {
    static let accessKey = "zD6R1jYSPZR9eKllVyMOQdJv86OOpjsBDeSDgLqBmqk"
    static let secretKey = "bBOYsAnHA7b8NNyExd6-WrHZpQt411PeBUjev8vKh-w"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Не удалось создать базовый URL")
        }
        return url
    }()
}
