import Foundation

public enum HttpOption {
    case hmacSHA256(header: String, privateKey: String)
    case timeout(seconds: Int)
    case session(URLSession)
    case allowUnsecureUrls
}
