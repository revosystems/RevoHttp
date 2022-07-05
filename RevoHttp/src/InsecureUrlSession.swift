import Foundation

class InsecureUrlSession : NSObject, URLSessionDelegate {
    
    var session:URLSession!
    
    override init() {
        super.init()
        session = URLSession.init(
            configuration: URLSession.shared.configuration,
            delegate: self,
            delegateQueue:URLSession.shared.delegateQueue
        )
    }
        
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       let trust: SecTrust = challenge.protectionSpace.serverTrust!
       let credential = URLCredential(trust: trust)
       completionHandler(.useCredential, credential)
    }
}
