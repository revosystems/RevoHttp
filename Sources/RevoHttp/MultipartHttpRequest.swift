import Foundation
import UIKit

public class MultipartHttpRequest : HttpRequest {
    
    var paramName:String?
    var fileName:String?
    var image:UIImage?
    let boundary = UUID().uuidString
    
    public func addMultipart(paramName: String, fileName: String, image: UIImage) -> MultipartHttpRequest{
        self.paramName  = paramName
        self.fileName   = fileName
        self.image      = image
        return self
    }
    
    public override func generate() -> URLRequest? {
        guard var urlRequest = super.generate() else { return nil }

        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    func generateData() -> Data {
        
        guard let paramName = self.paramName, let fileName = self.fileName, let image = self.image else { return Data() }
        
        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
    

}
