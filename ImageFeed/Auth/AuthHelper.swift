import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    private let clientId: String
    private let redirectURI: String
    private let accessScope: String
    private let authURLString: String
    
    init(clientId: String,
         redirectURI: String,
         accessScope: String,
         authURLString: String = Constants.unsplashAuthorizeURLString) {
        self.clientId = clientId
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
    }
    
    init(configuration: AuthConfiguration) {
        self.clientId = configuration.accessKey
        self.redirectURI = configuration.redirectURI
        self.accessScope = configuration.accessScope
        self.authURLString = configuration.authURLString
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
        
    }
    
    func authURL() -> URL? {
        guard var components = URLComponents(string: authURLString) else { return nil }
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        
        return components.url
    }
    
    func code(from url: URL) -> String? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.path == "/oauth/authorize/native",
            let codeItem = components.queryItems?.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
}
